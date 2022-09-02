## windows
1. Open the `Microsoft Store` and get updates for `App Installer`, which will ensure we have `winget`
1. Open `Powershell` and run the following:
    ```powershell
    winget install -e Git.Git
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
