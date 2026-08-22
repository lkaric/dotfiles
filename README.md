# dotfiles

Declarative macOS, one repo: nix-darwin + home-manager for everything that is
installed and wired, plain config files for everything that is looked at and
tweaked. Current host: `hephaestus` (Apple Silicon).

## 🧭 How it is organised

One rule: **Nix owns what is installed and how it is wired; `config/` owns how
things look and behave.**

- Rebuild (`nrs`) when you add a package, cask, font, runtime, or change a git/ssh identity or a macOS default.
- Never rebuild for Neovim, Ghostty, starship, sheldon, tmux, mise, atuin or Herdr config: those files live in `config/` and are symlinked into `~` out of the nix store, so edits are live.

```
flake.nix                  inputs + one darwinConfiguration per host
hosts/<name>/default.nix   hostname, primary user, wallpaper, host-only extras
modules/darwin/            system: nix, macOS defaults, homebrew casks, fonts, Touch ID
modules/home/              user: packages, zsh, git, ssh, docker, symlinks, agents, wallpaper
config/                    mutable configs (nvim, ghostty, starship, sheldon, tmux, mise, atuin, herdr, zsh, colima)
keys/                      public ssh keys + allowed_signers (private keys live in Bitwarden)
legacy/                    pre-nix snapshots, reference only
lefthook.yml               pre-commit formatters
```

## 🧰 The stack

Install column: `nix` = nixpkgs via home-manager, `cask` = Homebrew cask via nix-darwin, `mas` = App Store via nix-darwin, `flake` = the tool's own flake pinned in `flake.lock`, `mise` = runtime managed by mise.

### Terminal and shell

| Tool | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| Ghostty | terminal | cask | `config/ghostty/config` | no |
| zsh | shell (system `/bin/zsh`, HM writes `~/.zshrc`) | nix | `modules/home/shell.nix`, extras in `config/zsh/*.zsh` | nix part yes, `config/zsh` no |
| sheldon | zsh plugins (zsh-defer, omz git, syntax-highlighting, autosuggestions) | nix | `config/sheldon/plugins.toml` | no |
| starship | prompt | nix | `config/starship.toml` | no |
| atuin | shell history (ctrl-r), sync opt-in | nix | `config/atuin/config.toml` | no |
| eza | `ls` replacement, aliased as `ls`/`ll`/`la`/`lt` | nix | `modules/home/shell.nix` | yes |
| tmux | multiplexer (prefix `C-a`) | nix | `config/tmux/tmux.conf` | no |
| jq, yq, ripgrep, fd, ffmpeg, curl, wget | unix toolbox | nix | - | - |

### Editor

| Tool | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| Neovim + LazyVim | editor | nix | `config/nvim/` (starter layout, `lazy-lock.json` committed) | no |
| JetBrainsMono Nerd Font, Inter | terminal/editor icons, UI | nix-darwin `fonts.packages` | `modules/darwin/fonts.nix` | yes |

### AI agents

| Tool | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| Oh My Pi (`omp`) | terminal coding agent | flake (`programs.omp`) | `~/.omp/agent/` (mutable, see `config/omp/README.md`) | no |
| Herdr | agent workspace manager / multiplexer (prefix `C-b`) | flake | `config/herdr/config.toml` | no |

### Dev runtimes and git

| Tool | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| mise | runtimes: node lts, bun, pnpm, rust stable, `@nestjs/cli` | nix | `config/mise/config.toml` | no |
| git | two identities by remote URL, ssh signing | nix | `modules/home/git.nix` | yes |
| gh | GitHub CLI, two accounts | nix | `~/.config/gh` (mutable) | no |
| lefthook + nixfmt, stylua, taplo, prettier | repo hooks and formatters | nix | `lefthook.yml` | yes (tools), no (hooks) |

### Containers

| Tool | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| Colima | Docker VM (vz + virtiofs + rosetta) | nix | `config/colima/default.yaml` (template for new profiles) | no |
| docker CLI, compose, buildx | client side | nix | `modules/home/docker.nix` | yes |

### Apps

| App | What for | Install | Config | Rebuild? |
| --- | --- | --- | --- | --- |
| Zen | browser | cask | policies via `system.defaults.CustomUserPreferences."app.zen-browser.zen"`, rest via Firefox Sync | yes (policies) |
| SuperCmd v2 | launcher, clipboard, snippets, Raycast extensions | cask (tap `supercmdlabs/supercmd`) | in-app for now (see FAQ) | - |
| Bitwarden | passwords + SSH agent | cask | in-app (enable SSH agent once) | - |
| Rectangle | window snapping | cask | `CustomUserPreferences."com.knollsoft.Rectangle"` | yes |
| Caffeinated | keep awake | mas | `CustomUserPreferences."design.yugen.Caffeinated"` | yes |
| Spotify, Discord, Slack | the usual | cask | account-synced | - |

### System

| What | Where |
| --- | --- |
| Dock, Finder, keyboard repeat, trackpad, screenshots, dark mode | `modules/darwin/system-defaults.nix` |
| Wallpaper (per host) | `hosts/<name>/default.nix` -> `my.wallpaper` |
| Touch ID for sudo | `modules/darwin/security.nix` |
| Homebrew itself, casks, taps, App Store apps | `modules/darwin/homebrew.nix` |

## 🚀 Fresh macOS, step by step

Everything below is copy-pasteable. Expected result after each step in the
indented line.

1. First boot: create your user, sign in to your Apple ID (needed for App Store apps), then install the command line tools.
   ```sh
   xcode-select --install
   ```
   > `xcode-select -p` prints `/Library/Developer/CommandLineTools`.

2. Install Determinate Nix and open a new terminal.
   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
   nix run nixpkgs#hello
   ```
   > prints `Hello, world!`

3. Clone the repo over https (no ssh keys yet).
   ```sh
   mkdir -p ~/git && git clone https://github.com/lkaric/dotfiles ~/git/dotfiles && cd ~/git/dotfiles
   ```

4. First switch. This installs Homebrew (nix-homebrew), every cask and App Store app, fonts, macOS defaults, the wallpaper, your shell, and all CLI tools. It takes a while the first time (Herdr and omp build from source).
   ```sh
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#hephaestus
   ```
   > ends with `Activating home-manager configuration` and no error. Open a new Ghostty window: starship prompt, `ls` is eza. A reboot once is recommended so Dock/Finder defaults are fully applied.

5. Bitwarden: open it, sign in, Settings -> Enable SSH agent. Confirm the socket and the keys.
   ```sh
   ls -l ~/.bitwarden-ssh-agent.sock && ssh-add -l
   ```
   > two `ED25519` keys listed (`personal`, `hiveyard`). If the vault is locked, unlock it and retry.

6. Switch the repo remote to ssh and test both identities.
   ```sh
   git remote set-url origin git@github.com:lkaric/dotfiles.git
   ssh -T git@github.com
   ssh -T git@github-hiveyard
   ```
   > `Hi lkaric!` and `Hi mladenctrl!`

7. GitHub CLI, both accounts.
   ```sh
   gh auth login -h github.com   # lkaric, ssh, browser
   gh auth login -h github.com   # mladenctrl, ssh, browser
   gh auth status
   ```
   > both accounts listed; switch with `gh auth switch`.

8. Runtimes.
   ```sh
   mise install && mise doctor
   node -v && bun -v && pnpm -v && cargo --version
   ```

9. Docker via Colima.
   ```sh
   colima start && docker run --rm hello-world && docker compose version
   ```

10. Hooks and editor.
    ```sh
    ./bootstrap.sh        # lefthook install
    nvim                  # LazyVim syncs plugins from lazy-lock.json on first start
    ```

11. Things that cannot be declared (one-time, in-app):
    - [ ] Zen: sign in to Firefox Sync (bookmarks, extensions, settings)
    - [ ] SuperCmd: grant Accessibility + Screen Recording when asked, set hotkey, sign out of Raycast habits
    - [ ] Bitwarden: unlock method (Touch ID), vault timeout
    - [ ] Rectangle, Caffeinated: allow Accessibility / login items when prompted
    - [ ] Spotify, Discord, Slack: sign in
    - [ ] Terminal -> System Events automation prompt (wallpaper step): allow
    - [ ] Wallpaper: if `nrs` printed "not found", pick Chroma Blue once in System Settings -> Wallpaper, then `nrs`

12. Sanity checklist:
    - [ ] `nrs` a second time changes nothing and finishes in seconds
    - [ ] `readlink ~/.config/nvim` points into `~/git/dotfiles/config/nvim`
    - [ ] `git log --show-signature -1` in a personal repo and in a mladenctrl repo show the right key
    - [ ] `brew list --cask` equals the cask list in `modules/darwin/homebrew.nix`
    - [ ] `fc-list | grep -i "JetBrainsMono Nerd"` prints fonts

## 🆕 New host

```sh
cp -r hosts/hephaestus hosts/<name>
$EDITOR hosts/<name>/default.nix        # hostname, wallpaper, host extras
$EDITOR flake.nix                       # add darwinConfigurations.<name> = mkHost { ... }
sudo darwin-rebuild switch --flake .#<name>
```
Intel Mac: `system = "x86_64-darwin"` in `mkHost` and `formatter.x86_64-darwin`.

## 🔁 Daily commands

| Alias | Does |
| --- | --- |
| `nrs` | `sudo darwin-rebuild switch --flake ~/git/dotfiles#<host>` |
| `nup` | `nix flake update` + switch + `brew update && brew upgrade` |
| `ncg` | garbage-collect generations older than 14 days, optimise the store |
| `nfmt` | `nix fmt` over the repo |
| `dots` | `cd ~/git/dotfiles` |

Editing anything in `config/` needs nothing else. Commit when happy; lefthook formats on commit.

## ⬆️ Updating things

| Layer | How |
| --- | --- |
| nixpkgs, nix-darwin, home-manager | `nup`, or `nix flake update nixpkgs` then `nrs` |
| omp, Herdr | `nix flake update omp herdr` then `nrs`. For Herdr pin a new tag in `flake.nix` (`github:herdrdev/herdr/vX.Y.Z`) |
| Homebrew casks | `brew update && brew upgrade` (part of `nup`), or set `homebrew.onActivation.upgrade = true` to do it on every `nrs` |
| App Store apps | App Store updates, or `mas upgrade` |
| mise runtimes | `mise upgrade` (within the declared specs), `mise use -g node@lts` to change a spec, commit `config/mise/config.toml` |
| LazyVim plugins | `:Lazy update`, then commit `config/nvim/lazy-lock.json` |
| sheldon plugins | `sheldon lock --update` |
| Determinate Nix | `sudo determinate-nixd upgrade` |
| macOS | System Settings (manual); after a major upgrade run `nrs` once |

Rollback after a bad update: see ⏪.

## 🔐 Identities

| Identity | GitHub | Key (Bitwarden item / pubkey) | Triggered by |
| --- | --- | --- | --- |
| personal (default) | `lkaric` | `personal` / `keys/personal.pub` | every remote not listed below |
| hiveyard | `mladenctrl` | `hiveyard` / `keys/hiveyard.pub` | any remote under `github.com/mladenctrl/` (ssh or https) |

- Clone work repos normally: `git clone git@github.com:mladenctrl/<repo>`; git rewrites the host to `github-hiveyard` and uses the hiveyard key, and `includeIf` switches name/email/signing key. Check with `git config user.email` inside the repo.
- Signing: `gpg.format = ssh`, `commit.gpgsign` (enabled in `modules/home/git.nix` once both pubkeys are registered as **Signing keys** on GitHub). Local verification uses `keys/allowed_signers`.
- All keys are served by the Bitwarden SSH agent (`SSH_AUTH_SOCK` and `IdentityAgent` point at `~/.bitwarden-ssh-agent.sock`). No private keys on disk.
- New key: Bitwarden -> New item -> SSH key (generate or import), copy the public key into `keys/<name>.pub`, add to `keys/allowed_signers`, reference it in `modules/home/ssh.nix` (and `git.nix` if it signs), `nrs`, add it on GitHub.
- Rotate: same as above, then delete the old item and pubkey.
- `gh` has both accounts: `gh auth switch -u lkaric|mladenctrl`.

## 📦 Adding things

| Want | Do |
| --- | --- |
| CLI tool | `modules/home/packages.nix` -> `home.packages`, `nrs` |
| GUI app (cask) | `modules/darwin/homebrew.nix` -> `casks`, `nrs`. Third-party tap: add to `taps` and `nix-homebrew.trust.taps` |
| App Store app | `masApps."Name" = <id>` (id from `mas search Name`), `nrs` |
| Font | `modules/darwin/fonts.nix`, `nrs` |
| Runtime | `mise use -g <tool>@<version>` (writes `config/mise/config.toml`), commit |
| zsh alias/function | `config/zsh/*.zsh`, open a new shell |
| New mutable config | put it in `config/`, add a `link` line in `modules/home/dotfiles.nix`, `nrs` once |
| macOS default | `modules/darwin/system-defaults.nix` (see nix-darwin options), `nrs` |
| Dock app | `system.defaults.dock.persistent-apps` |

## 🪝 Git hooks

`lefthook.yml` runs on staged files at pre-commit and re-stages fixes:
nixfmt (`*.nix`), stylua (`*.lua`), taplo (`*.toml`), prettier (`*.md|yml|yaml|json`, except `lazy-lock.json`).

- Install once per clone: `./bootstrap.sh` (or `lefthook install`)
- Skip once: `LEFTHOOK=0 git commit ...`
- Whole repo: `nix fmt` (nix) or `lefthook run pre-commit --all-files`

## ⏪ Rollback and recovery

| Situation | Do |
| --- | --- |
| Last `nrs` broke something | `darwin-rebuild --list-generations`, then `sudo darwin-rebuild --rollback` (or `--switch-generation N`) |
| Flake update broke a build | `git checkout flake.lock && nrs` |
| HM refuses: "would be clobbered" | it moved the file to `<file>.bak`; diff, delete the `.bak`, `nrs` |
| Homebrew cleanup removed an app you wanted | add it to `casks`, `nrs` (with `cleanup = "zap"` anything undeclared is removed on switch) |
| Shell broken | `/bin/zsh -f`, then `nrs`; the previous generation is always bootable |
| Disk full | `ncg` |

## 🐳 Docker via Colima

```sh
colima start            # first start creates the VM from config/colima/default.yaml
colima status
colima stop
colima start --edit     # change cpu/memory of the existing profile
docker context ls       # "colima" is current after start
```
Autostart at login: set `my.colima.autostart = true` in `hosts/<name>/default.nix` under `home-manager.users.<you>`.

## 🗺️ FAQ

- **Why casks for GUI apps and not nixpkgs?** macOS app bundles from nixpkgs are second class (no auto-update, Spotlight/Launch Services quirks). Casks are declarative through nix-darwin and `cleanup = "zap"` keeps the set exact.
- **Why are configs out of the store?** LazyVim writes `lazy-lock.json`, mise writes `config.toml`, Ghostty reloads live. `mkOutOfStoreSymlink` keeps them editable and still tracked.
- **Why mise and not nix for node/rust?** Per-project versions (`.mise.toml`, `.nvmrc`) and `cargo install` just work; nix provides mise itself.
- **Why no nix-managed `~/.config/gh` or `~/.omp`?** Both tools rewrite their own files at runtime.
- **SuperCmd settings?** Electron app, state under `~/Library/Application Support/SuperCmd/`. When it settles into a single settings file, copy it to `config/supercmd/` and add a `link` in `dotfiles.nix`.
- **Herdr vs tmux?** Both installed. Herdr for agent sessions (mouse-first, `C-b`), tmux for plain shells (`C-a`), so prefixes do not collide.
- **Chrome is gone; the Claude-in-Chrome extension needs it.** Add `"google-chrome"` to `casks` if you want it back.
