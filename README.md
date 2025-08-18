## macos
### Bootstrapping the `setup.sh` script
1. Sign-in to apple ID
1. Start a download for a system update
1. Install homebrew via [brew.sh](brew.sh)
1. While that's happening, sign in to [github.com](github.com).
1. `brew install gh`
1. `gh auth login`
1. `gh repo clone matthewgrossman/dotfiles`
1. `cd dotfiles/mac; ./setup.sh`

The first program installed should be `google-drive`, which is a first priority to get access to keepass.
1. Sign into Google Drive
1. Open keepassxc with `gdrive://sync/pwdb.kdbx`

This script will end up prompting for password a few times (ideally at the beginning), so check on it periodically.

`setup.sh` should handle lots of default macos settings, but AFAIK these still require manual clicking:
1. Disable cmd-space for spotlight in keyboard settings (and modify alfred to use this instead)
1. Turn off auto-brightness in Displays
1. Enable bluetooth in the top bar

#### Alfred
1. Enter the powerpack info, search gdrive for "alfred"
1. Point the settings at `gdrive://sync/alfred.kdbx`
1. Change the theme
1. Enable clipboard history

#### Steermouse
1. Search email for "steermouse" to get the registration info.
1. If you haven't in awhile, export the profile from the old machine into `gdrive://sync/`
1. Import settings of `gdrive://sync/Default.smsetting_app`
1. The most recent time I did this, I had issues that simply restarting resolved. I also had to unplug my dock, which was wild.


## windows
1. Open `Powershell` **as administrator** and run the following:
    ```powershell
    winget install -e Git.Git
    cd $HOME
    git clone https://github.com/matthewgrossman/dotfiles
    powershell -ExecutionPolicy Bypass -File .\dotfiles\windows\setup.ps1
    ```

There are some apps that can't easily be installed via that script:
- The NVIDIA app

## wsl2 / ubuntu
1. Ensure you have github-allowlisted ssh keys
1. Run the following:
```bash
$> git clone git@github.com:matthewgrossman/dotfiles.git
$> cd dotfiles
$> sh link.sh
$> sh windows/setup_wsl.sh
```
