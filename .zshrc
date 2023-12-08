# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===============
# Path and general ZSH config
# ===============
export PATH=$HOME/bin:$HOME/.bin:/usr/local/bin:$HOME/.local/bin:/usr/bin/Postman:/usr/local/go/bin:/$HOME/go/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ===============
# Shortcuts
# ===============
alias a-timestamp="date +%s"

alias a-clear-swap='sudo swapoff -a; sudo swapon -a'

alias a-docker-stop='docker rm -f $(docker ps -a -q)'

alias a-docker-clean='docker system prune -a --volumes'

alias a-top-du='du -Sh | sort -rh | head -10'

function f-ssh() {
  local IP=$1
  local KEY=$2
  local USER=$3

  local SSH_KEYS_DIRECTORY=${SSH_KEYS_DIR:-""}

  if [ -z "${KEY}" ]; then
    KEY=$(ls "${SSH_KEYS_DIRECTORY}" | rofi -dmenu -p "window" -mesg "Select ssh key")
  fi

  if [ -z "${USER}" ]; then
    USER=$(rofi -dmenu -p "window" -mesg "Enter username")
  fi

  local KEY_FILE=$(find "${SSH_KEYS_DIRECTORY}" -name "*${KEY}*")
  local FOUND_KEYS=$(echo "${KEY_FILE}" | wc -l)

  if [[ ${FOUND_KEYS} -eq 1 ]]; then
    ssh -i "${KEY_FILE}" "${USER}@${IP}"
  else
    echo -e "Error, found more than one key with name ${KEY}:\n${KEY_FILE}"
  fi
}

IGNORE_DIRS=('.svn' '.git' '.hg' 'node_modules' 'build-Release' 'build-Debug' 'build-*', 'var-lib-docker')
IGNORE_FILES=('*.lock' '*.map' '*.min.js' '*.factorypath' '*.dot' '*.svg')

# Find files by name, matching a word, recursively
# https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command/#16595367
# Note: Using '-ipath' instead of '-iname', because the former allows searchs
#       such as 'my/path/somefile', while the latter doesn't.
f-find() {
  local IGND
  IGND=$(printf -- "-not \( -path './*/%s' -prune \) " "${IGNORE_DIRS[@]}")
  local ARGS
  ARGS=$(printf -- "-o -ipath '*%s*' " "$@")

  # shellcheck disable=SC2086
  eval find . $IGND -false $ARGS
}


# Find inside files, recursively
# http://askubuntu.com/questions/55325/how-to-use-grep-command-to-find-text-including-subdirectories
IGNORE_DIRS=(
    ".angular"
    "node_modules"
    "static"
)
f-grep() {
  local IGND
  IGND=$(printf -- "--exclude-dir='%s' " "${IGNORE_DIRS[@]}")
  local IGNF
  IGNF=$(printf -- "--exclude='%s' " "${IGNORE_FILES[@]}")
  local ARGS
  ARGS=$(printf -- "-e '%s' " "$@")

  # shellcheck disable=SC2086
  eval grep --color=always -FiIr $IGND $IGNF $ARGS .
}

f-cpu-usage() { mpstat -P ALL 2 5000 ;}

f-ipscan() { nmap -sn 192.168.1.0/24 ;}

f-iplan() {
    # https://stackoverflow.com/questions/13322485/how-to-get-the-primary-ip-address-of-the-local-machine-on-linux-and-os-x/49552792#49552792
    # "1" is shorthand for "1.0.0.0"
    case "$OSTYPE" in
        linux*) ip -4 -oneline route get 1 | grep -Po 'src \K([\d.]+)' ;;
        darwin*) ipconfig getifaddr "$(route -n get 1 | sed -n 's/.*interface: //p')" ;;
    esac
}

f-delgit() {
    find . -name .git -type d -o -name .gitignore        -print0 | xargs -0 rm -rfv
}

# Get the 20 biggest directories in the current path
f-dirsizes() {
    du --human-readable --summarize ./* \
        | sort --human-numeric-sort --reverse \
        | head --lines=20
}

# Print open File Descriptors in use from a given path
f-lsof-dir() {
    lsof +D "$1"
}

# Print open File Descriptors (FD) in use by a given program
# Argument: program name (e.g. "nano") or path to it (e.g. "/bin/nano")
f-lsof-prog() {
    local PID
    PID="$(pgrep --newest --full "$1")" || return
    echo "FD count: $(find "/proc/$PID/fd" -mindepth 1 -maxdepth 1 -printf '\n' | wc -l)"
    lsof -a -p "$PID" -d '^cwd,^err,^ltx,^mem,^mmap,^pd,^rtd,^txt'
}

f-listusers() {
    awk -F':' '{ print "name=" $1 " uid=" $3 " gid=" $4 " comment=" $5 " home="$6 }' /etc/passwd
}

f-listgroups() {
    awk -F':' '{ print "name=" $1 " gid=" $3 " users=" $4 }' /etc/group
}

# Extract any type of compressed file
f-extract() {
    [[ -f "$1" ]] || { echo "File not valid: '$1'"; return 1; }
    case "$1" in
        *.tar)     tar xvf "$1" ;;
        *.tar.gz)  tar zxvf "$1" ;;
        *.tgz)     tar zxvf "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar.bz2) tar jxvf "$1" ;;
        *.tbz)     tar jxvf "$1" ;;
        *.tbz2)    tar jxvf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.tar.Z)   tar Zxvf "$1" ;;
        *.taz)     tar Zxvf "$1" ;;
        *.Z)       uncompress "$1" ;;
        *.tar.lz)  tar --lzip -xvf "$1" ;;
        *.tlz)     tar --lzip -xvf "$1" ;;
        *.tar.xz)  tar Jxvf "$1" ;;
        *.txz)     tar Jxvf "$1" ;;
        *.xz)      unxz -dkv "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.zip)     unzip "$1" ;;
        *.7z)      7z x "$1" ;;
        *)         echo "Don't know how to extract '$1'..." ;;
    esac
}

f-dexec() {
    local CONTAINER_ID=$(docker ps | awk '{if(NR>1)print}' | rofi -dmenu -p "window" -mesg "Select a container" | awk '{ print $1 }')
    docker exec -it ${CONTAINER_ID} /bin/bash || docker exec -it ${CONTAINER_ID} /bin/sh
}

f-dlogs() {
    ARGS=$1
    local CONTAINER_ID=$(docker ps | awk '{if(NR>1)print}' | rofi -dmenu -p "window" -mesg "Select a container" | awk '{ print $1 }')
    docker logs ${ARGS} ${CONTAINER_ID}
}

beep() {
    eval "$@"
    RC=$?
    timeout --signal=ABRT 1s speaker-test --test sine --frequency 1000 --scale 10 >/dev/null
    return $RC
}

f-countdown(){
    date1=$((`date +%s` + $1));
    while [ "$date1" -ge `date +%s` ]; do 
        ## Is this more than 24h away?
        days=$(($(($(( $date1 - $(date +%s))) * 1 ))/86400))
        echo -ne "$days day(s) and $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r"; 
        sleep 0.1
    done
    beep
}

f-stopwatch(){
    date1=`date +%s`;
    while true; do
        days=$(( $(($(date +%s) - date1)) / 86400 ))
        echo -ne "$days day(s) and $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
        sleep 0.1
    done
}

f-new-mail-text() {
    title="${1}"
    if [[ -z "$title" ]]; then
        echo "Title for mail not defined"
    else
        title="$(date +%s)-${title}"
        mkdir -p "${MAILS_DIR}"
        cd "${MAILS_DIR}"
        mkdir -p "${title}" && cd "${title}"
    fi
}

f-new-quick-temporal-project() {
    title="${1}"
    if [[ -z "$title" ]]; then
        echo "Title for quick temporal project is not defined"
    else
        title="$(date +%s)-${title}"
        mkdir -p "${TEMPORAL_PROJECTS_DIR}"
        cd "${TEMPORAL_PROJECTS_DIR}"
        mkdir -p "${title}" && cd "${title}"
    fi
}

f-new-quick-project() {
    title="${1}"
    if [[ -z "$title" ]]; then
        echo "Title for quick project is not defined"
    else
        title="$(date +%s)-${title}"
        mkdir -p "${QUICK_PROJECTS_DIR}"
        cd "${QUICK_PROJECTS_DIR}"
        mkdir -p "${title}" && cd "${title}"
    fi
}

goto() {
    PROJECT=$(ls "${HOME}/DevProjects" | rofi -dmenu -p "window" -mesg "Select a project")
    PROJECT_DIR="${HOME}/DevProjects/${PROJECT}"
    REPOSITORY=$(ls "${PROJECT_DIR}" | rofi -dmenu -p "window" -mesg "Select a repository")
    REPOSITORY_DIR="${PROJECT_DIR}/${REPOSITORY}"
    cd "${REPOSITORY_DIR}"
}

f-goto-mail() {
    PROJECT=$(ls "${MAILS_DIR}" | rofi -dmenu -p "window" -mesg "Select a mail")
    EMAIL_DIR="${MAILS_DIR}/${PROJECT}"
    cd "${EMAIL_DIR}"
}

f-goto-quick-project() {
    PROJECT=$(ls "${QUICK_PROJECTS_DIR}" | rofi -dmenu -p "window" -mesg "Select a quick project")
    PROJECT_DIR="${QUICK_PROJECTS_DIR}/${PROJECT}"
    cd "${PROJECT_DIR}"
}

f-focus-time() {
    # Backup the current hosts file
    sudo cp /etc/hosts /etc/hosts.backup

    echo -e "127.0.0.1 ${NON_USEFUL_WEBS}" | sudo tee -a /etc/hosts
}

f-unfocus-time() {
    if [[ -f "/etc/hosts.backup" ]]; then
        sudo cp /etc/hosts.backup /etc/hosts
        sudo rm /etc/hosts.backup
    fi
}

dexec() {
    if [ -z "$1" ]; then
        echo "Error: No container specified. Please specify a container."
        return 1
    fi
    docker exec -it $1 /bin/bash || docker exec -it $1 /bin/sh
}


# Default editor
export EDITOR="$(which code)"
# Defaults to VSCode for git commit messages
git config --global core.editor "code --wait"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[[ ! -f ~/.zshrc-private ]] || source ~/.zshrc-private

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
