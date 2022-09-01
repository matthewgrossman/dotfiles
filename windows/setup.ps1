# winget import $PSScriptRoot\winget.json

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex

choco install razer-synapse-3
choco install 7zip

wsl --install --distribution Ubuntu
