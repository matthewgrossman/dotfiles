## macos
### Bootstrapping the `setup.sh` script
1. Sign-in to apple ID
1. Start a download for a system update
1. Install homebrew via [brew.sh](brew.sh)
1. Temporarily add Homebrew to this shell with `eval "$(/opt/homebrew/bin/brew shellenv)"`; do not add it to `.zshrc`, since `link.sh` will install the dotfiles
1. While that's happening, sign in to [github.com](github.com).
1. `brew install gh`
1. `gh auth login`
1. `gh repo clone matthewgrossman/dotfiles`
1. `cd dotfiles/mac; ./setup.sh`

The first program installed should be `google-drive`, which is a first priority to get access to keepass.
1. Sign into Google Drive
1. Open keepassxc with `gdrive://sync/pwdb.kdbx`

This script will end up prompting for password a few times (ideally at the beginning), so check on it periodically.

#### KeePassXC
1. Enable browser integration in Settings > Browser Integration
1. Disable "Lock databases when the session is locked or the lid is closed"
1. Prevent KeePassXC from replacing the database file so KeePassium does not lose its file reference:
   - Go to Settings > General > Basic Settings > File Management
   - Enable "Use alternative saving method" and select "Directly write to database file (dangerous)"
   - Enable "Backup database file before saving"
   - If KeePassium already lost the file reference, open the existing database again from KeePassium's Databases screen
   - See the [KeePassium troubleshooting guide](https://support.keepassium.com/kb/database-does-not-exist/) for details

#### SOPS age key
The `homelab` repository uses [SOPS](https://github.com/getsops/sops) with
[age](https://github.com/FiloSottile/age) to keep secrets encrypted in Git. To
edit or decrypt those secrets on a new computer, retrieve the SOPS age private
key from the password manager and install it at SOPS's default key location:

```sh
mkdir -p ~/.config/sops/age
# use keepassxc to download keys.txt to `~/.config/sops/age/keys.txt`
```

Never commit or otherwise copy this private key into either repository.

`setup.sh` should handle lots of default macos settings, but AFAIK these still require manual clicking:
1. Disable cmd-space for spotlight in keyboard settings (and modify alfred to use this instead)
1. Map Caps Lock to Control in System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys
1. Select the denser scaled resolution in System Settings > Displays
1. Set up the display arrangement for the desk in System Settings > Displays > Arrange
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


## Herdr
`config/herdr/config.toml` holds shared daemon/TUI settings;
`config/herdr/config-gpui.local.toml` holds GUI overrides and reloads automatically.
`link.sh` links tracked files into `~/.config/herdr/` individually, leaving
generated defaults (`config-gpui.toml`), runtime data, and credentials outside Git.

## Agent skills
Run `./install-skills.sh` to install all local skills and the selected external
skills globally for the configured agents. Requires Node.js and npm (`npx`).
Local skills live in `skills/<name>/SKILL.md`; new ones are installed automatically
without changing the script.
Edit the `SKILLS` array to change the selection. Rerunning refreshes the listed
skills without removing existing ones. The script then runs
`~/dev/workfiles/install-skills.sh` if it exists.

## Pi
Pi's global configuration is tracked in `config/pi/`. `PI_CODING_AGENT_DIR` is
set to `$XDG_CONFIG_HOME/pi`, so the normal file-linking behavior in `link.sh`
symlinks tracked Pi files into `~/.config/pi/`. That destination remains a real
directory because Pi also stores credentials, sessions, trust decisions,
downloaded model metadata, and installed package data alongside its config.
Only the explicitly tracked files are symlinked into the repository. Pi may
update runtime metadata in the tracked `settings.json` file.

After bootstrapping, authenticate Pi separately with `/login`; credentials are
not stored in this repository. Packages listed in the tracked settings are
installed by Pi when needed.


## windows
1. Open `Powershell` **as administrator** and run the following:
    ```powershell
    winget install -e Git.Git
    cd $HOME
    git clone https://github.com/matthewgrossman/dotfiles
    powershell -ExecutionPolicy Bypass -File .\dotfiles\windows\setup.ps1
    ```

There are some apps that can't be installed via that script:
- The NVIDIA app
- AMD Chipset Driver ("Adrenalin")

## wsl2 / ubuntu
1. Ensure you have github-allowlisted ssh keys
1. Run the following:
```bash
$> git clone git@github.com:matthewgrossman/dotfiles.git
$> cd dotfiles
$> sh link.sh
$> sh windows/setup_wsl.sh
```
