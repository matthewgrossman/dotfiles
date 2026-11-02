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

#### Homelab CA
My self-hosted services use HTTPS certificates from my own CA, and accept only
my devices (mTLS). Each device trusts the CA once; after that, a new server
just needs a certificate from it, and nothing changes on the devices.
[mkcert](https://github.com/FiloSottile/mkcert) issues the certificates;
`.zshrc` points it at the CA with `CAROOT=~/dev/certs`. Never run
`mkcert -install`: it would make this Mac trust the CA.

`~/dev/certs` is never committed, and is backed up as one attachment on the
"Homelab CA" entry in KeePassXC:

| File | What | Who gets a copy |
|---|---|---|
| `rootCA.pem` | The CA's certificate, "homelab CA" (10 years, until Oct 2036) | Devices, to trust servers; servers, to check devices |
| `rootCA-key.pem` | The CA's private key | Nobody |
| `clients.pem` | Every allowed device's certificate | Servers, which accept only these |

Issuing any certificate needs both `rootCA.pem` and `rootCA-key.pem`.
`clients.pem` is my list; each server has its own copy, so any change to it
means updating every server.

Back up after every change, and restore on a new computer:

```sh
tar -czf certs.tgz -C ~/dev certs       # attach to the "Homelab CA" entry, then delete
mkdir -p ~/dev && tar -xzf certs.tgz -C ~/dev
```

##### Creating the CA (once)
mkcert would name its own CA after this Mac and user, so it's made with openssl:

```sh
mkdir -p ~/dev/certs && cd ~/dev/certs
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -days 3650 \
  -keyout rootCA-key.pem -out rootCA.pem -subj "/CN=homelab CA" \
  -addext "basicConstraints=critical,CA:TRUE,pathlen:1" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"
```

`pathlen:1` lets it sign intermediate CAs, but not intermediates of those.

##### Adding an intermediate CA
For a machine that should issue its own certificates without the root key.
It's limited to one domain, so its key can't be used to impersonate other
sites to my devices. Devices need nothing new.

```sh
cd ~/dev/certs && d=lab.mrg.lol && t=$(mktemp -d)
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $t/key.pem
openssl req -new -key $t/key.pem -subj "/CN=homelab $d CA" |
  openssl x509 -req -CA rootCA.pem -CAkey rootCA-key.pem -days 1826 -out $t/cert.pem \
    -extfile <(printf '%s\n' "basicConstraints=critical,CA:TRUE,pathlen:0" \
      "keyUsage=critical,keyCertSign,cRLSign" "nameConstraints=critical,permitted;DNS:$d" \
      "subjectKeyIdentifier=hash" "authorityKeyIdentifier=keyid")
```

Give the machine `$t/cert.pem` and `$t/key.pem` (then `rm -rf $t`). There,
mkcert issues from it with `CAROOT` pointing at a folder holding them as
`rootCA.pem` and `rootCA-key.pem`. Servers must send their certificate
followed by the intermediate's, and every host name must be under the domain.
Name devices like email addresses (`mkcert -client ... iphone@homelab`), which
the limit doesn't cover. Intermediates last 5 years; renew the same way.

##### Adding a server, or renewing its certificate
Server certificates last 825 days (iOS's limit). Use a name that resolves to
the server, e.g. a wildcard under `mrg.lol`:

```sh
mkcert '*.home.mrg.lol'   # writes ./_wildcard.home.mrg.lol.pem and -key.pem
```

Give the server those two files, plus `rootCA.pem` and `clients.pem` if it
should require my devices, then delete the local copies. Server certificates
aren't backed up; issue a new one when needed.

##### Adding a device
E.g. an iPhone:

```sh
cd ~/Downloads
mkcert -client -pkcs12 -p12-file iphone.p12 iphone     # password: changeit
openssl pkcs12 -legacy -in iphone.p12 -passin pass:changeit -nokeys -clcerts |
  openssl x509 >>~/dev/certs/clients.pem
```

1. AirDrop `~/dev/certs/rootCA.pem` and `iphone.p12` to the phone (if iOS
   doesn't recognize the `.pem`, copy it to a `.crt` name first).
2. Settings → General → VPN & Device Management: install both (the `.p12`
   password is `changeit`).
3. Settings → General → About → Certificate Trust Settings: turn on full trust
   for "homelab CA". iOS doesn't do this on its own, and without it the phone
   silently drops connections.
4. Delete `iphone.p12` from the Mac.
5. Back up `~/dev/certs`, and update `clients.pem` on every server. Until then
   they reject the new device.

A device certificate can also come from an intermediate CA. It's still one
identity for every server, but servers should trust that intermediate's
certificate alongside `rootCA.pem`, rather than rely on the device to send it.

##### Revoking a device
Delete its block from `clients.pem` (list them with
`openssl crl2pkcs7 -nocrl -certfile ~/dev/certs/clients.pem | openssl pkcs7 -print_certs -noout`),
then back up and update every server, as when adding one. Caddy refuses to
start with an empty `clients.pem`, so to revoke the last device, stop the
servers instead.

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

`config/herdr/bin/hvim` keeps one headless nvim per Herdr workspace and opens a
view of it (`--remote-ui`) in the current pane, so every pane edits the same
buffers. Cmd-clicked file paths use it via `editor_command`. Leave a view with
`:detach`; `:q` on the last window stops the shared nvim. Inside Herdr, zsh puts
it on `PATH` and uses `hvim --wait` (returns once the buffer is closed) as `$VISUAL`.

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

## Useful tools
A persistent bookmark list of handy web tools.

- [gif.statico.io](https://gif.statico.io/) — GIF tool

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
