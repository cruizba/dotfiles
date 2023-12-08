#!/bin/bash

VSCODE_EXT=(
    "74th.monokai-charcoal-high-contrast"
    "davidlday.languagetool-linter"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "esbenp.prettier-vscode"
    "foxundermoon.shell-format"
    "franneck94.c-cpp-runner"
    "GitHub.copilot"
    "GitHub.copilot-chat"
    "github.vscode-github-actions"
    "golang.go"
    "hediet.vscode-drawio"
    "johnpapa.angular-essentials"
    "johnpapa.angular2"
    "kddejong.vscode-cfn-lint"
    "lizebang.bash-extension-pack"
    "mads-hartmann.bash-ide-vscode"
    "marp-team.marp-vscode"
    "mikestead.dotenv"
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-wsl"
    "ms-vscode-remote.vscode-remote-extensionpack"
    "ms-vscode.cmake-tools"
    "ms-vscode.cpptools"
    "ms-vscode.cpptools-extension-pack"
    "ms-vscode.cpptools-themes"
    "ms-vscode.hexeditor"
    "ms-vscode.makefile-tools"
    "ms-vscode.powershell"
    "ms-vscode.remote-explorer"
    "ms-vscode.remote-server"
    "orta.vscode-jest"
    "pkief.material-icon-theme"
    "rafmsou.nicer-high-contrast"
    "rangav.vscode-thunder-client"
    "redhat.fabric8-analytics"
    "redhat.java"
    "redhat.vscode-yaml"
    "remisa.shellman"
    "riccardonovaglia.missinglineendoffile"
    "rogalmic.bash-debug"
    "rpinski.shebang-snippets"
    "sketchbuch.vsc-zen-terminal-button"
    "timonwong.shellcheck"
    "tomoki1207.pdf"
    "twxs.cmake"
    "vadimcn.vscode-lldb"
    "visualstudioexptteam.intellicode-api-usage-examples"
    "visualstudioexptteam.vscodeintellicode"
    "vmware.vscode-spring-boot"
    "vscjava.vscode-java-debug"
    "vscjava.vscode-java-dependency"
    "vscjava.vscode-java-pack"
    "vscjava.vscode-java-test"
    "vscjava.vscode-maven"
    "vscodevim.vim"
    "ybaumes.highlight-trailing-white-spaces"
    "yzane.markdown-pdf"
)


function install_vscode() {
    sudo apt-get install wget gpg -y
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt install apt-transport-https -y
    sudo apt update
    sudo apt install code -y

    for ext in "${VSCODE_EXT[@]}"; do
        code --install-extension "${ext}"
    done

    mkdir -p ~/.config/Code/User
    # Copy settings.json
    cp .config/Code/User/settings.json ~/.config/Code/User/settings.json

    # Replace home directory
    sed -i "s|ENV_HOME|$HOME|g" ~/.config/Code/User/settings.json
}

install_vscode
