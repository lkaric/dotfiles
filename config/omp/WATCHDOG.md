# Review priorities

You are reviewing work in a nix-darwin + home-manager dotfiles repo. Weight
your attention accordingly.

## Blockers

- **Declared state that cannot be written.** A `home.file`/`xdg.configFile`
  entry pointing into the nix store for a config the app rewrites at runtime.
  The app fails with EACCES on first write. Anything an app owns must go
  through `config.lib.file.mkOutOfStoreSymlink` (the `link` helper in
  `modules/home/dotfiles.nix`) or an activation-time copy.
- **Secrets in the repo.** Private keys, API tokens, `hosts.yml`-style auth
  files, atuin keys. Public keys under `keys/` are fine; private keys live in
  Bitwarden.
- **`homebrew.onActivation.cleanup = "zap"`.** Removing a cask from the list
  uninstalls it _and_ runs its zap stanza, which can trash user config dirs.
  Call that out before anyone drops an entry.
- **Identity leaks.** Work identity (`hiveyard`) applied to personal remotes or
  the reverse. Selection is by remote URL, not directory, and `insteadOf`
  rewrites do not apply before `includeIf`.

## Concerns

- Settings written to the wrong layer: `omp config set` writes the global
  `config.yml`, so a value that must survive a rebuild belongs in
  `programs.omp.settings` or `config/omp/settings.yml`, not in a shell command
  someone ran once.
- Array-valued nix or omp settings being _replaced_ rather than merged across
  layers, silently dropping entries defined lower down.
- New manual setup steps that are not encoded in activation or at least
  recorded in the README checklist. If a fresh machine cannot reproduce it, say
  so.
- Docs contradicting the code after an edit: the README tables, `config/*/README.md`,
  and the FAQ all make specific claims about install method and mutability.

## Nits worth one line

- Formatter compliance: `nixfmt` for `*.nix`, `taplo` for `*.toml`, `prettier`
  for `*.{md,yml,yaml,json}`. Hooks may not be installed in a given clone.
- Comments that explain _why_ a workaround exists, not what the code does.
  Every non-obvious knob in this repo has a reason; keep it next to the knob.

## Do not

- Do not flag GUI apps installed as casks rather than nixpkgs. That is a
  deliberate, documented convention (see the FAQ).
- Do not propose tracking a file the owning app rewrites unless the write path
  is verified to resolve symlinks.
