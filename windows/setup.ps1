# essentials
winget install Mozilla.Firefox --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Google.Chrome --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Spotify.Spotify --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install OpenWhisperSystems.Signal --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Google.Drive --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install KeePassXCTeam.KeePassXC --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Microsoft.PowerToys --accept-package-agreements --disable-interactivity --accept-source-agreements

# hardware
winget install Nvidia.GeForceExperience --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Intel.IntelDriverAndSupportAssistant --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install AMD.RyzenMaster --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install REALiX.HWiNFO --accept-package-agreements --disable-interactivity --accept-source-agreements

# programming
winget install Microsoft.WindowsTerminal --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install tailscale.tailscale --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install RealVNC.VNCViewer --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Iterate.Cyberduck --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install calibre.calibre --accept-package-agreements --disable-interactivity --accept-source-agreements

# gaming
winget install Valve.Steam --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install EpicGames.EpicGamesLauncher --accept-package-agreements --disable-interactivity --accept-source-agreements
winget install Discord.Discord --accept-package-agreements --disable-interactivity --accept-source-agreements

# extras if you want to program on this machine:

# install scoop {{{
# Start-Process powershell -Verb runAs -ArgumentList "-file $PSScriptRoot\setup_admin.ps1"
#
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
# irm get.scoop.sh | iex
#
# scoop bucket add nerd-fonts
# scoop bucket add extras
# scoop update
#
# scoop install win32yank
# scoop install CascadiaCode-NF
#
# [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "\\wsl.localhost\Ubuntu\home\mg\dotfiles\config\wezterm", 'User')

# }}}
