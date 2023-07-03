
# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex

choco install -y razer-synapse-3
choco install -y 7zip
choco install -y firacode

wsl --install --distribution Ubuntu
