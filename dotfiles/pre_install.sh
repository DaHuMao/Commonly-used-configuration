echo install brew -----------------------------
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" || echo failed install brew
echo successed install brew -----------------------------

echo install rg -----------------------------
brew install rg || echo failed install rg
echo successed install rg -----------------------------

echo install nvim -----------------------------
brew install nvim || echo failed install nvim
echo successed install nvim -----------------------------

echo install nvm ---------------------------------
brew install nvm || echo failed install nvm
nvm install 13.2.0 || exit 1
nvm use 13.2.0
nvm alias default 13.2.0
echo successed install -----------------------------




