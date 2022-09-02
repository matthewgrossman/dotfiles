Start-Process powershell -Verb runAs -ArgumentList "-file $PSScriptRoot\setup_admin.ps1"

# install scoop {{{
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex

scoop bucket add nerd-fonts
scoop update

scoop install win32yank
scoop install CascadiaCode-NF
# }}}
