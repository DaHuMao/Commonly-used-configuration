#!/bin/zsh
# 清理废弃的 zsh_complete socket 文件
# 用法: ./cleanup_zsh_complete_sockets.zsh [--dry-run] [--verbose]

set -e

SOCKET_DIR="$HOME/.myzsh/zsh_complete/.socket"
DRY_RUN=false
VERBOSE=false
MAX_AGE_DAYS=7  # 默认 7 天

# 格式化时间差为可读形式
format_time_ago() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))
    local days=$((hours / 24))

    if (( days > 0 )); then
        printf "%d天%d小时前" $days $((hours % 24))
    elif (( hours > 0 )); then
        printf "%d小时%d分钟前" $hours $((minutes % 60))
    elif (( minutes > 0 )); then
        printf "%d分钟前" $minutes
    else
        printf "%d秒前" $seconds
    fi
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --age|--max-age)
            if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "❌ 错误: --age 需要一个数字参数（天数）"
                exit 1
            fi
            MAX_AGE_DAYS=$2
            shift 2
            ;;
        --help|-h)
            echo "用法: $(basename $0) [选项]"
            echo ""
            echo "选项:"
            echo "  --age DAYS              删除指定天数未被使用的 socket (默认: 7 天)"
            echo "  --dry-run               只显示会被删除的文件，不实际删除"
            echo "  --verbose, -v           显示详细信息"
            echo "  --help, -h              显示此帮助信息"
            echo ""
            echo "例子:"
            echo "  $(basename $0)              # 删除 7 天未使用的 socket"
            echo "  $(basename $0) --age 14     # 删除 14 天未使用的 socket"
            echo "  $(basename $0) --age 1 --dry-run --verbose"
            exit 0
            ;;
        *)
            echo "❌ 未知选项: $1"
            exit 1
            ;;
    esac
done

# 检查目录是否存在
if [[ ! -d "$SOCKET_DIR" ]]; then
    echo "❌ Socket 目录不存在: $SOCKET_DIR"
    exit 1
fi

echo "🔍 开始扫描 socket 文件..."
echo "   目录: $SOCKET_DIR"
echo "   删除规则: 未被使用超过 $MAX_AGE_DAYS 天的 socket 文件"
echo ""

cleaned=0
total=0
still_active=0
zombies=0
unused=0
MAX_AGE_SECONDS=$((MAX_AGE_DAYS * 86400))  # 转换为秒

# 遍历所有 socket 文件
for socket_file in "$SOCKET_DIR"/*; do
    # 跳过不存在的文件
    [[ -e "$socket_file" ]] || continue

    total=$((total + 1))
    filename=$(basename "$socket_file")

    # 从文件名中提取 PID
    # 假设格式是: .zsh_complete_client_PID
    pid=$(echo "$filename" | sed 's/.*_//')

    # 检查 PID 是否是有效的数字
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        if [[ "$VERBOSE" == true ]]; then
            echo "⚠️  文件名格式不符: $filename"
        fi
        continue
    fi

    # 获取文件访问时间
    local access_time=$(stat -f "%a" "$socket_file" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local age_seconds=$((current_time - access_time))
    local time_ago=$(format_time_ago $age_seconds)

    # 检查进程状态
    # ps 的 STATE 字段: R=运行中, S=睡眠, D=磁盘等待, Z=僵尸, T=暂停, W=分页
    local proc_state=$(ps -o state= -p "$pid" 2>/dev/null)

    if [[ -z "$proc_state" ]]; then
        # 进程不存在
        cleaned=$((cleaned + 1))
        if [[ "$DRY_RUN" == true ]]; then
            echo "🗑️  [模拟删除] 废弃 socket: $filename"
            echo "              └─ PID $pid 不存在 | 最后访问: $time_ago"
        else
            echo "🗑️  删除废弃 socket: $filename"
            echo "              └─ PID $pid 不存在 | 最后访问: $time_ago"
            rm -f "$socket_file"
        fi
    elif [[ "$proc_state" == "Z" ]]; then
        # 僵尸进程
        zombies=$((zombies + 1))
        cleaned=$((cleaned + 1))
        if [[ "$DRY_RUN" == true ]]; then
            echo "🗑️  [模拟删除] 僵尸进程: $filename"
            echo "              └─ PID $pid 已变成僵尸 | 最后访问: $time_ago"
        else
            echo "🗑️  删除僵尸进程的 socket: $filename"
            echo "              └─ PID $pid 已变成僵尸 | 最后访问: $time_ago"
            rm -f "$socket_file"
        fi
    else
        # 活跃进程，检查是否超过最大使用期限
        if (( age_seconds > MAX_AGE_SECONDS )); then
            # 超过最大使用期限，删除
            unused=$((unused + 1))
            cleaned=$((cleaned + 1))
            if [[ "$DRY_RUN" == true ]]; then
                echo "🗑️  [模拟删除] 长期未使用: $filename"
                echo "              └─ PID $pid | 状态: $proc_state | 最后访问: $time_ago (超过 $MAX_AGE_DAYS 天)"
            else
                echo "🗑️  删除长期未使用的 socket: $filename"
                echo "              └─ PID $pid | 状态: $proc_state | 最后访问: $time_ago (超过 $MAX_AGE_DAYS 天)"
                rm -f "$socket_file"
            fi
        else
            # 在使用期限内的活跃进程
            still_active=$((still_active + 1))
            echo "✓ 活跃进程: $filename"
            echo "              └─ PID $pid | 状态: $proc_state | 最后访问: $time_ago"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 清理统计:"
echo "   总文件数:       $total"
echo "   活跃进程:       $still_active"
echo "   僵尸进程:       $zombies"
echo "   长期未使用:     $unused (> $MAX_AGE_DAYS 天)"
if [[ "$DRY_RUN" == true ]]; then
    echo "   ─────────────────────────"
    echo "   [模拟]删除数:  $cleaned"
else
    echo "   ─────────────────────────"
    echo "   已删除数:      $cleaned"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$DRY_RUN" == true ]]; then
    echo "ℹ️  这是模拟运行 (--dry-run)，没有实际删除文件"
    echo "   如果结果满意，请运行: $(basename $0)"
fi

exit 0
