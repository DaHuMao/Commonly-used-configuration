let g:deoplete#enable_at_startup = 1
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'python': ['pyls', '-v',  '-v', '--log-file=/tmp/pyls.log'],
    \ 'cpp': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'c': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'go': ["go-langserver", "-gocodecompletion", "-lint-tool", "golint"]
    \ }

let g:LanguageClient_rootMarkers = {
    \ 'rust': ['Cargo.toml'],
    \ 'python': ['.root'],
    \ }

let $RUST_BACKTRACE = 1
let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_settingsPath = '~/.config/nvim/settings.json'
let g:LanguageClient_serverStderr = '/tmp/langserver.log'
let g:LanguageClient_loggingFile ="/tmp/langclient.log"
