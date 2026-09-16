#!/usr/bin/env bash

_git_function_print_commit_ids() {
  local commit_list="$1"
  printf 'commit ids:\n' >&2
  while IFS= read -r line; do
    [[ -n "${line// }" ]] || continue
    printf '%s\n' "$line" >&2
  done <<EOF
$commit_list
EOF
}

_git_function_assert_clean_state() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    log_error "当前仓库有未提交的修改，请先处理后再执行 cherry-pick"
    return 1
  fi
  if git rev-parse -q --verify CHERRY_PICK_HEAD >/dev/null 2>&1; then
    log_error "当前仓库已有未完成的 cherry-pick，请先处理"
    return 1
  fi
  if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    log_error "当前仓库已有未完成的 merge，请先处理"
    return 1
  fi
  if git rev-parse -q --verify REBASE_HEAD >/dev/null 2>&1; then
    log_error "当前仓库已有未完成的 rebase，请先处理"
    return 1
  fi
}

_git_function_usage_git_show_file() {
  cat <<'EOF' >&2
用法:
  git_show_file <commit_id>
EOF
}

_git_function_usage_cherry_pick() {
  cat <<'EOF' >&2
用法:
  cherry_pick <source_branch> <commit_count>
EOF
}

git_show_file() {
  local commit_id="${1:-}"

  [[ $# -eq 1 && -n "$commit_id" ]] || {
    _git_function_usage_git_show_file
    return 1
  }

  git rev-parse --verify "${commit_id}^{commit}" >/dev/null 2>&1 || {
    log_error "git_show_file: 无效的 commit id: ${commit_id}"
    return 1
  }

  git show --pretty='' --name-only "$commit_id" | sed '/^[[:space:]]*$/d'
}

cherry_pick() {
  local source_branch="${1:-}"
  local commit_count="${2:-}"
  local current_branch=""
  local raw_commit_list=""
  local commit_list=""
  local actual_count=0
  local commit=""

  [[ $# -eq 2 && "$commit_count" =~ ^[1-9][0-9]*$ ]] || {
    _git_function_usage_cherry_pick
    return 1
  }

  _git_function_assert_clean_state || return 1

  current_branch="$(_git_function_current_branch)" || return 1

  git fetch origin "$source_branch" >/dev/null 2>&1 || {
    log_error "cherry_pick: 拉取源分支失败: ${source_branch}"
    return 1
  }
  git show-ref --verify --quiet "refs/remotes/origin/${source_branch}" || {
    log_error "cherry_pick: 远端分支不存在: origin/${source_branch}"
    return 1
  }

  raw_commit_list="$(git log --format=%H -n "$commit_count" "refs/remotes/origin/${source_branch}")"
  [[ -n "$raw_commit_list" ]] || {
    log_error "cherry_pick: 分支 ${source_branch} 上没有可 cherry-pick 的 commit"
    return 1
  }

  actual_count="$(_git_function_count_non_empty_lines "$raw_commit_list")"
  [[ "$actual_count" == "$commit_count" ]] || {
    log_error "cherry_pick: 分支 ${source_branch} 上不足 ${commit_count} 个 commit，实际只有 ${actual_count} 个"
    return 1
  }

  commit_list="$(_git_function_reverse_lines "$raw_commit_list")"
  printf '[cherry_pick] current_branch=%s source_branch=%s count=%s\n' "$current_branch" "$source_branch" "$commit_count" >&2
  _git_function_print_commit_ids "$commit_list"

  while IFS= read -r commit; do
    [[ -n "$commit" ]] || continue
    printf '[cherry_pick] cherry-pick %s\n' "$commit" >&2
    if ! git cherry-pick "$commit"; then
      log_error "cherry_pick: cherry-pick ${commit} 发生冲突，已停止；当前冲突现场已保留，请处理后自行继续"
      _git_function_print_commit_ids "$commit_list"
      return 1
    fi
  done <<EOF
$commit_list
EOF
}

function new_branch(){
  branch_name=$1
  git checkout -b $branch_name
  git push --set-upstream origin $branch_name
}

function git_has_modified_files() {
  local quiet=0
  local worktree_output=""
  local index_output=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --quiet)
        quiet=1
        ;;
      *)
        echo "用法: git_has_modified_files [--quiet]"
        return 2
        ;;
    esac
    shift
  done

  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库"
    return 2
  fi

  worktree_output=$(git diff --name-only --ignore-submodules=all -- 2>&1)
  local worktree_res=$?
  if [ $worktree_res -ne 0 ]; then
    echo "❌ 检查工作区改动失败"
    echo "$worktree_output"
    return $worktree_res
  fi

  index_output=$(git diff --cached --name-only --ignore-submodules=all -- 2>&1)
  local index_res=$?
  if [ $index_res -ne 0 ]; then
    echo "❌ 检查暂存区改动失败"
    echo "$index_output"
    return $index_res
  fi

  if [ -n "$worktree_output" ] || [ -n "$index_output" ]; then
    if [ $quiet -eq 0 ]; then
      echo "检测结果: 有已跟踪文件改动"
      if [ -n "$worktree_output" ]; then
        echo "工作区修改文件:"
        echo "$worktree_output"
      fi
      if [ -n "$index_output" ]; then
        echo "暂存区修改文件:"
        echo "$index_output"
      fi
      echo "说明: 纯未跟踪新文件不会命中这个检测"
    fi
    return 0
  fi

  if [ $quiet -eq 0 ]; then
    echo "检测结果: 没有已跟踪文件改动"
    echo "说明: 纯未跟踪新文件不会命中这个检测"
  fi
  return 1
}

function git_push() {
  local res=0
  local need_stash_pop=0
  local current_branch=""
  local output=""
  local stash_ref=""
  local stash_before_ref=""
  local stash_after_ref=""
  local has_local_changes=0
  local push_force=0

  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--force)
        push_force=1
        ;;
      *)
        echo "用法: git_push [-f|--force]"
        return 1
        ;;
    esac
    shift
  done

  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库"
    res=1
  fi

  if [ $res -eq 0 ]; then
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$current_branch" ] || [ "$current_branch" = "HEAD" ]; then
      echo "❌ 错误：未获取到当前分支，请先切到一个本地分支"
      res=1
    else
      echo "当前分支: $current_branch"
    fi
  fi

  if [ $res -eq 0 ]; then
    git_has_modified_files --quiet
    local local_changes_res=$?
    if [ $local_changes_res -eq 0 ]; then
      has_local_changes=1
    elif [ $local_changes_res -gt 1 ]; then
      res=$local_changes_res
    fi
  fi

  if [ $res -eq 0 ] && [ $has_local_changes -eq 1 ]; then
      stash_before_ref=$(git rev-parse --verify refs/stash 2>/dev/null)
      output=$(git stash push -m "git_push auto stash" 2>&1)
      local stash_res=$?
      if [ $stash_res -ne 0 ]; then
        echo "❌ git stash 执行失败"
        echo "$output"
        res=$stash_res
      else
        stash_after_ref=$(git rev-parse --verify refs/stash 2>/dev/null)
        if [ -n "$stash_after_ref" ] && [ "$stash_after_ref" != "$stash_before_ref" ]; then
          stash_ref="$stash_after_ref"
          need_stash_pop=1
          echo "ℹ️ 检测到本地改动，已自动执行 git stash"
        else
          echo "❌ 检测到本地改动，但 git stash 未生成新的 stash 条目"
          echo "$output"
          res=1
        fi
      fi
  fi

  if [ $res -eq 0 ] && [ $push_force -eq 0 ]; then
    output=$(git pull --rebase 2>&1)
    local pull_res=$?
    if [ $pull_res -ne 0 ]; then
      echo "❌ git pull --rebase 执行失败"
      echo "$output"
      res=$pull_res
    fi
  fi

  if [ $res -eq 0 ]; then
    if [ $push_force -eq 1 ]; then
      output=$(git push -f origin "$current_branch" 2>&1)
    else
      output=$(git push origin "$current_branch" 2>&1)
    fi
    local push_res=$?
    if [ $push_res -ne 0 ]; then
      if [ $push_force -eq 1 ]; then
        echo "❌ git push -f origin $current_branch 执行失败"
      else
        echo "❌ git push origin $current_branch 执行失败"
      fi
      echo "$output"
      res=$push_res
    fi
  fi

  echo $output

  if [ $need_stash_pop -eq 1 ]; then
    output=$(git stash pop 2>&1)
    local stash_pop_res=$?
    if [ $stash_pop_res -ne 0 ]; then
      echo "❌ git stash pop 执行失败"
      echo "$output"
      if [ $res -eq 0 ]; then
        res=$stash_pop_res
      fi
    else
      echo "ℹ️ 已自动恢复之前的本地改动"
    fi
  fi

  return $res
}

function _remove_branch_single() {
  local branch="$1"
  # 自动去除用户输入的 origin/ 前缀，避免误输入
  branch=${branch#origin/}

  # 2. 校验当前目录是否为Git仓库
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库"
    return 1
  fi

  # 3. 校验当前分支是否为待删除分支，避免删当前分支报错
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" = "$branch" ]; then
    echo "❌ 错误：当前正处于待删除分支 $branch 上，请先切换到其他分支再执行"
    return 1
  fi

  # 4. 删除本地分支
  echo -e "\n>>> 正在处理本地分支: $branch"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    # 优先安全删除：仅分支已合并到主干才允许删除
    if git branch -d "$branch" 2>/dev/null; then
      echo "✅ 本地分支 $branch 删除成功"
    else
      # 未合并分支二次确认强制删除
      echo "⚠️  本地分支 $branch 未完全合并到当前分支，是否强制删除? (y/N)"
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        git branch -D "$branch"
        echo "✅ 本地分支 $branch 已强制删除"
      else
        echo "⏭️  已跳过本地分支删除"
      fi
    fi
  else
    echo "⏭️  本地不存在分支 $branch，跳过本地删除"
  fi

  # 5. 删除远程分支
  echo -e "\n>>> 正在处理远程(origin)分支: $branch"
  if git ls-remote --exit-code --heads origin "$branch" > /dev/null 2>&1; then
    if git push origin --delete "$branch"; then
      echo "✅ 远程分支 origin/$branch 删除成功"
      # 自动清理本地无效的远程追踪分支引用
      git fetch --prune
      echo "✅ 已自动清理本地无效的远程分支追踪记录"
    else
      echo "❌ 远程分支删除失败，请检查仓库权限或分支状态"
      return 1
    fi
  else
    echo "⏭️  远程不存在分支 $branch，跳过远程删除"
  fi

  echo -e "\n🎉 分支清理操作执行完成"
}

function remove_branch() {
  if [ $# -eq 0 ]; then
    echo "用法: remove_branch <分支名1> [分支名2] ..."
    echo "功能: 依次删除多个 Git 分支（本地和远程 origin）"
    return 1
  fi

  local res=0
  local branch

  for branch in "$@"; do
    _remove_branch_single "$branch"
    if [ $? -ne 0 ]; then
      res=1
    fi
  done

  return $res
}
