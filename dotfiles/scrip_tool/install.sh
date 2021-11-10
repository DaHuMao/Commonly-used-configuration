SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

for ele in `ls $SCRIPT_DIR/script`
do
  chmod 777 $SCRIPT_DIR/script/$ele
  ln -sf "$SCRIPT_DIR/script/$ele" ~/bin/$ele
done
#ln -sf "$SCRIPT_DIR/script/countp.sh" ~/bin/countp.sh
#ln -sf "$SCRIPT_DIR/script/plot.py" ~/bin/plot.py
#ln -sf "$SCRIPT_DIR/script/plot.sh" ~/bin/plot.sh
#ln -sf "$SCRIPT_DIR/script/dezip.sh" ~/bin/dezip.sh
#ln -sf "$SCRIPT_DIR/script/format.sh" ~/bin/format.sh
#ln -sf "$SCRIPT_DIR/script/git-add.sh" ~/bin/git-add.sh

