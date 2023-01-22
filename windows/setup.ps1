Start-Process powershell -Verb runAs -ArgumentList "-file $PSScriptRoot\setup_admin.ps1"

# essentials
winget install Mozilla.Firefox --accept-package-agreements
winget install Google.Chrome --accept-package-agreements
winget install Microsoft.Edge --accept-package-agreements
winget install Spotify.Spotify --accept-package-agreements
winget install OpenWhisperSystems.Signal --accept-package-agreements
winget install Google.Drive --accept-package-agreements
winget install KeePassXCTeam.KeePassXC --accept-package-agreements
winget install Microsoft.PowerToys --accept-package-agreements

# hardware
winget install Nvidia.GeForceExperience --accept-package-agreements
winget install Intel.IntelDriverAndSupportAssistant --accept-package-agreements
winget install AMD.RyzenMaster --accept-package-agreements
winget install REALiX.HWiNFO --accept-package-agreements

# programming
winget install Microsoft.WindowsTerminal --accept-package-agreements
winget install Git.Git --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements
winget install RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements
winget install tailscale.tailscale --accept-package-agreements
winget install IVPN.IVPN --accept-package-agreements
winget install RealVNC.VNCViewer --accept-package-agreements
winget install Iterate.Cyberduck --accept-package-agreements
winget install calibre.calibre --accept-package-agreements

# gaming
winget install Valve.Steam --accept-package-agreements
winget install EpicGames.EpicGamesLauncher --accept-package-agreements
winget install Parsec.Parsec --accept-package-agreements
winget install Discord.Discord --accept-package-agreements

Refresh-Environment

# install scoop {{{
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex

Refresh-Environment

scoop bucket add nerd-fonts
scoop bucket add extras
scoop update

scoop install win32yank
scoop install CascadiaCode-NF
# }}}
