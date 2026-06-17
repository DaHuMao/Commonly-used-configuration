function open_au() {
  open -a "Adobe Audition 2024" $1
}

function open_as() {
  open -a "Android Studio" $1
}

function open_as_new {
  open -na "Android Studio" --args "$1"
}

function new_branch(){
  branch_name=$1
  git checkout -b $branch_name
  git push --set-upstream origin $branch_name
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

