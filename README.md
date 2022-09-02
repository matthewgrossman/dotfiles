## windows
1. Open `Powershell` as administrator
1. Run the following: 
```powershell
cd $HOME; git clone https://github.com/matthewgrossman/dotfiles; . .\dotfiles\windows\setup.ps1
```

## wsl2 / ubuntu
1. Ensure you have github-allowlisted ssh keys
1. Run the following:
```bash
$> git clone git@github.com:matthewgrossman/dotfiles.git
$> cd dotfiles
$> sh link.sh
$> sh windows/setup_wsl.sh
```
