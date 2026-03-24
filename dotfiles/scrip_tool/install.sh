set -o errexit
source ../zsh/bin/tool_function.sh
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

TAR_DIR=$HOME/bin/
SafeMkDir $TAR_DIR

for ele in `ls $SCRIPT_DIR/script`
do
  chmod 777 $SCRIPT_DIR/script/$ele
  mklink "$SCRIPT_DIR/script/$ele" $TAR_DIR/$ele
done
