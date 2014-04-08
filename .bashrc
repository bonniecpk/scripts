alias clearOrig='echo "Removing .orig files..."; find . -name "*.orig" | while read -d $'\''\n'\'' file; do rm -v "$file"; done;'
alias clearLocal='echo "Removing .LOCAL files..."; find . -name "*.LOCAL.*" | while read -d $'\''\n'\'' file; do rm -v "$file"; done;'
alias clearBackup='echo "Removing .BACKUP files..."; find . -name "*.BACKUP.*" | while read -d $'\''\n'\'' file; do rm -v "$file"; done;'
alias clearRemote='echo "Removing .REMOTE files..."; find . -name "*.REMOTE.*" | while read -d $'\''\n'\'' file; do rm -v "$file"; done;'
alias clearBase='echo "Removing .BASE files..."; find . -name "*.BASE.*" | while read -d $'\''\n'\'' file; do rm -v "$file"; done;'
alias clearCrap='clearOrig clearLocal clearBackup clearRemote clearBase'

alias fixError='git mergetool -t opendiff'
alias cont='git rebase --continue'

alias push='git push origin $(git_current_branch)'
alias pull='git pull origin $(git_current_branch)'

function git_current_branch() {
  git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///'
}
