./pre_install.ps1
. myposh/tool.ps1
. myposh/to_bash_cmd.ps1

$initProfilePath = $PROFILE
mkfile_and_mv $initProfilePath
cp init.ps1 $initProfilePath


# (3) 判断 ~/.myposh 目录并创建或删除
$myposhDir = "$HOME/.myposh"
mkdir_and_rm $myposhDir

$srcPath = "./myposh"
$linkPath = "$myposhDir/posh_config"
mklink $srcPath $linkPath
mklink ./bin $myposhDir/bin

cp env_config.ps1 $myposhDir/env_config.ps1

log_info "install and update powershell module"
. $PROFILE
