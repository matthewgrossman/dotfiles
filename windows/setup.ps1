# essentials
winget install --id Mozilla.Firefox --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Google.Chrome --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Spotify.Spotify --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id OpenWhisperSystems.Signal --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Google.GoogleDrive --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id KeePassXCTeam.KeePassXC --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Microsoft.PowerToys --accept-package-agreements --disable-interactivity --accept-source-agreements --exact

# hardware
winget install --id Intel.IntelDriverAndSupportAssistant --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id REALiX.HWiNFO --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Rufus.Rufus --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id UltimateGadgetLaboratories.UHKAgent --accept-package-agreements --disable-interactivity --accept-source-agreements --exact

# programming
winget install --id Microsoft.WindowsTerminal --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Microsoft.VisualStudioCode --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id tailscale.tailscale --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id RealVNC.VNCViewer --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Iterate.Cyberduck --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id calibre.calibre --accept-package-agreements --disable-interactivity --accept-source-agreements --exact

# gaming
winget install --id Valve.Steam --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id EpicGames.EpicGamesLauncher --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id Discord.Discord --accept-package-agreements --disable-interactivity --accept-source-agreements --exact
winget install --id ClassicOldSong.Apollo --accept-package-agreements --disable-interactivity --accept-source-agreements --exact

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
