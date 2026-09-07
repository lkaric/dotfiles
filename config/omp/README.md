omp keeps mutable state under `~/.omp/agent/` (agent.db, sessions, blobs,
extensions). Config reaches it through three layers, in increasing authority.

| Layer                                               | Written by                                                                         | Use for                                                                                 |
| --------------------------------------------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `programs.omp.settings` (`modules/home/agents.nix`) | the flake's HM module copies it to `config.yml` (`install -m 600`) on every switch | anything you may want to change live in the TUI and have reasserted on the next rebuild |
| `~/.omp/agent/config.yml`                           | omp itself (`omp config set`, `/settings`, `/model`)                               | nothing tracked - **fully overwritten on every switch**, see below                      |
| `settings.yml` (this dir, via `PI_CONFIG_FILES`)    | you, by hand                                                                       | policy that must always win; omp reads overlays and never writes them                   |

Full precedence: `defaults` < `config.yml` < `<cwd>/.omp/config.yml` < `PI_CONFIG_FILES` < `--config` < runtime flags.
Objects deep-merge; **scalars and arrays are replaced wholesale**.

The practical rule: appearance and comfort settings go in `programs.omp.settings`
so `/theme` and `Alt+M` still work between rebuilds. Model routing, tool
enablement, and concurrency limits go in `settings.yml` so nothing can quietly
override them. A key in `settings.yml` cannot be changed persistently from the
TUI - `/model`'s Roles view will appear to accept it and then revert.

`setupVersion = 2` in `programs.omp.settings` is load-bearing: without it omp
re-runs the onboarding wizard on the next launch.

## config.yml is replaced, not merged

`programs.omp.settings` does `install -m 600 <generated.yml> ~/.omp/agent/config.yml`.
That is a wholesale replacement: **any key you set at runtime and did not
declare is gone after the next `nrs`**, and so is any key omp itself wrote.

So the declared set must cover everything that has to survive a rebuild. It
currently does, with exactly three exceptions, all deliberate:

| Key in `config.yml` but not declared | Why it is safe                     |
| ------------------------------------ | ---------------------------------- |
| `memory.backend`                     | pinned in `settings.yml` (overlay) |
| `astGrep.enabled`                    | pinned in `settings.yml`           |
| `task.maxConcurrency`                | pinned in `settings.yml`           |

Because those three live only in the overlay, they depend on `PI_CONFIG_FILES`
being set. It is exported twice on purpose: `home.sessionVariables` for shells,
and `launchd.user.envVariables` (`modules/darwin/default.nix`) for everything
else - GUI-launched apps and anything they spawn, none of which descends from
a zsh that sourced `.zshenv`.

To check what is actually live after a rebuild:

```sh
omp config get modelRoles      # merged view across both layers
echo $PI_CONFIG_FILES          # non-empty, or the overlay is not loading
```

## Assets symlinked into `~/.omp/agent/`

Declared in `modules/home/dotfiles.nix`. omp reads these and never writes them.

| Path                | Becomes                    | What it is                                                                   |
| ------------------- | -------------------------- | ---------------------------------------------------------------------------- |
| `agents/*.md`       | `~/.omp/agent/agents`      | custom subagents; `architect` is a read-only design agent on the `plan` role |
| `skills/*/SKILL.md` | `~/.omp/agent/skills`      | skills; `herdr` teaches omp to drive Herdr panes                             |
| `WATCHDOG.md`       | `~/.omp/agent/WATCHDOG.md` | review priorities appended to the advisor's prompt (never the primary's)     |

Regenerate the Herdr skill after a Herdr version bump - it ships inside the
binary:

```sh
herdr --skill > config/omp/skills/herdr/SKILL.md
```

Other things omp reads that could be tracked the same way, once you author one:

- `commands/*.md` -> `~/.omp/agent/commands` - custom `/slash` commands
- `rules/*.md` -> `~/.omp/agent/rules` - rulebook entries (`description` + `globs`, body fetched on demand via `rule://`)
- `AGENTS.md` -> `~/.omp/agent/AGENTS.md` - user-level context file (shadows `~/.claude/CLAUDE.md` and friends)
- `keybindings.yml` -> `~/.omp/agent/keybindings.yml` - flat `action.id: Chord` map, not part of `config.yml`

## Installed by activation, not symlinked

`modules/home/agents.nix` reruns these on every switch because both are
version-matched to a binary:

- `herdr integration install omp` -> `~/.omp/agent/extensions/herdr-omp-agent-state.ts`.
  omp has no Herdr screen-detection manifest, so without this every omp pane
  shows as `unknown` in the Herdr sidebar.
- `omp browser-relay install` -> `~/.omp/browser-relay/extension` (only if
  missing). Loading it into Chrome stays manual.
