# essentials
winget install --accept-package-agreements --disable-interactivity --accept-source-agreements --exact `
    Mozilla.Firefox `
    Google.Chrome `
    Spotify.Spotify `
    OpenWhisperSystems.Signal `
    Google.GoogleDrive `
    KeePassXCTeam.KeePassXC `
    Microsoft.PowerToys

# hardware
winget install --accept-package-agreements --disable-interactivity --accept-source-agreements --exact `
    Intel.IntelDriverAndSupportAssistant `
    REALiX.HWiNFO `
    Rufus.Rufus `
    UltimateGadgetLaboratories.UHKAgent `
    Rem0o.FanControl

# programming
winget install --accept-package-agreements --disable-interactivity --accept-source-agreements --exact `
    Microsoft.WindowsTerminal `
    Microsoft.VisualStudioCode `
    RaspberryPiFoundation.RaspberryPiImager `
    tailscale.tailscale `
    RealVNC.VNCViewer `
    Iterate.Cyberduck `
    calibre.calibre

# gaming
winget install --accept-package-agreements --disable-interactivity --accept-source-agreements --exact `
    Valve.Steam `
    EpicGames.EpicGamesLauncher `
    Discord.Discord `
    ClassicOldSong.Apollo

# misc
winget install --accept-package-agreements --disable-interactivity --accept-source-agreements --exact `
    Bambulab.Bambustudio `
    7zip.7zip `
    Sonos.Controller `
    Chocolatey.Chocolatey

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
