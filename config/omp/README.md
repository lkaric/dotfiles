omp keeps mutable state under `~/.omp/agent/` (config.yml, models.yml, agent.db,
sessions, blobs). `omp config set` and `/settings` rewrite `config.yml` in place,
so it is deliberately **not** symlinked here.

What this directory holds instead:

| Path           | How omp loads it                                                                                                                                                           |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `settings.yml` | `PI_CONFIG_FILES` (set in `modules/home/agents.nix`). omp reads overlays and never writes them, and they outrank `config.yml`, so this is the declarative source of truth. |
| `agents/`      | symlinked to `~/.omp/agent/agents` (`modules/home/dotfiles.nix`). Custom subagents, one `*.md` per agent.                                                                  |

Precedence, low to high:
`defaults` < `~/.omp/agent/config.yml` < `<cwd>/.omp/config.yml` < `PI_CONFIG_FILES` < `--config` < runtime flags.

Objects deep-merge across layers; **scalars and arrays are replaced wholesale**.
So `modelRoles.default` can stay mutable in `config.yml` while `settings.yml`
pins `plan`/`slow`/`smol`/`task`, but any array here replaces the one below it.

Because the overlay outranks `config.yml`, keys listed in `settings.yml` cannot
be changed from the TUI persistently — `/model`'s Roles view will appear to work
and then revert. Edit `settings.yml` and restart omp. Check what is actually
live with `omp config get <key>`.

Other things omp reads that could be tracked here the same way (add a `home.file`
link in `modules/home/dotfiles.nix` when you author one):

- `commands/*.md` -> `~/.omp/agent/commands` - custom `/slash` commands
- `rules/*.md` -> `~/.omp/agent/rules` - rulebook entries (`description` + `globs`, body fetched on demand via `rule://`)
- `skills/<name>/SKILL.md` -> `~/.omp/agent/skills` - skills (`description` is what routes them)
- `AGENTS.md` -> `~/.omp/agent/AGENTS.md` - user-level context file (shadows `~/.claude/CLAUDE.md` and friends)
- `keybindings.yml` -> `~/.omp/agent/keybindings.yml` - flat `action.id: Chord` map, not part of config.yml
