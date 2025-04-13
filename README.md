## macos
1. Sign-in to apple ID
1. Start a download for a system update
1. Install homebrew via [brew.sh](brew.sh)
1. While that's happening, sign in to [github.com](github.com).
1. `brew install gh`
1. `gh auth login`
1. `gh repo clone matthewgrossman/dotfiles`
1. `cd dotfiles/mac; ./setup.sh`

Once a whole bunch of programs have installed, a first priority is to get access to keepass.
1. Sign into Google Drive
1. Open keepassxc with`sync/pwdb.kdbx`

This script will end up prompting for password a few times (ideally at the beginning), so check on it periodically.

`setup.sh` should handle lots of default macos settings, but AFAIK these still require manual clicking:
1. Disable cmd-space for spotlight in keyboard settings
1. Turn off auto-brightness

#### Alfred
1. Enter the powerpack info, search gdrive for "alfred"
1. Point the settings at `gdrive://sync/alfred.kdbx`
1. Change the theme
1. Enable clipboard history

#### Steermouse


## windows
1. Open the `Microsoft Store` and get updates for `App Installer`, which will ensure we have `winget`
1. Open `Powershell` and run the following:
    ```powershell
    winget install -e Git.Git
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
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
