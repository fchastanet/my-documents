---
title: Two Claude Code Accounts with Two WSL Users
linkTitle: Claude Perso/Pro WSL Users
description: Keep a personal and a professional Claude Code configuration side by side by giving each its own WSL user, and switch VS Code between them with the switchToPersoUser / switchToWslUser aliases.
pageInfo: |-
  One WSL distro, two Linux users (wsl = pro, perso = personal): separate Claude Code logins, settings, sessions,
  git identities and VS Code extensions, with a one-command switch of the VS Code default user.
type: docs
weight: 50
categories:
  - AI
  - Bash
  - Tooling
tags:
  - claude-code
  - productivity
  - vscode
  - wsl
date: '2026-11-19T08:00:00+01:00'
lastmod: '2026-11-19T08:00:00+01:00'
version: '1.0'
---

<!--TOC-->

- [1. Why two WSL users](#1-why-two-wsl-users)
- [2. The VS Code constraint](#2-the-vs-code-constraint)
- [3. Creating the second user](#3-creating-the-second-user)
- [4. The `wsl-default-user` script](#4-the-wsl-default-user-script)
- [5. The `switchToPersoUser` / `switchToWslUser` aliases](#5-the-switchtopersouser--switchtowsluser-aliases)
- [6. Showing the default user in the prompt](#6-showing-the-default-user-in-the-prompt)
- [7. First login as perso](#7-first-login-as-perso)
- [8. Caveats](#8-caveats)

<!--TOC-->

## 1. Why two WSL users

Claude Code keeps everything that identifies an account in the home directory:

| Path                          | Content                                                     |
| ----------------------------- | ----------------------------------------------------------- |
| `~/.claude/.credentials.json` | the OAuth login (which subscription/organization is billed) |
| `~/.claude/settings.json`     | user settings, permissions, hooks                           |
| `~/.claude/projects/`         | session transcripts and per-project memory                  |
| `~/.claude/skills/`, plugins  | personal skills and plugins                                 |
| `~/.claude.json`              | per-project trust, MCP servers, onboarding state            |
| `~/.vscode-server/`           | VS Code extensions (Claude Code extension and its login)    |

The goal is to never mix both worlds: personal conversations must not end up in the company account (and the reverse),
personal repositories must be committed with the personal git identity, and the pro MCP servers/credentials must not be
reachable from personal projects.

`CLAUDE_CONFIG_DIR` can point the CLI to another config directory, but it only covers Claude Code itself: git identity,
`gh` login, ssh keys, cloud credentials and the VS Code extension stay shared. A second Linux user isolates all of them
at once, for free, with standard Unix permissions.

Resulting layout in a single distro (`Ubuntu2404` in the examples):

- `wsl`: pro account (company Claude login, company git identity, `~/projects`)
- `perso`: personal account (personal Claude login, personal git identity, `~/perso`)

## 2. The VS Code constraint

Terminals are not a problem: both users can be used at the same time.

```bash
# Windows Terminal profile for perso
wsl -d Ubuntu2404 -u perso --cd ~
```

Think about updating Windows Terminal profile to use the `wsl` user instead of the default one, otherwise when switching
between users you might end up in the wrong account.

```bash
# Windows Terminal profile for wsl
wsl -d Ubuntu2404 -u wsl --cd ~
```

VS Code is: **"WSL: Connect" always logs in as the distro's default user**, there is no option to choose the user
([vscode-remote-release#286](https://github.com/microsoft/vscode-remote-release/issues/286)). The default user is the
`[user] default=` entry of `/etc/wsl.conf`, read only when the distro starts:

```ini
[user]
default=perso
```

So switching VS Code from one account to the other means: change that line, then restart the distro. That is what the
`wsl-default-user` script and the two aliases automate.

## 3. Creating the second user

Run as the existing (pro) user `wsl`:

```bash
# zsh, sudo, serial ports, docker, and read access to wsl's files
sudo useradd --create-home --shell /usr/bin/zsh --groups sudo,dialout,docker,wsl perso

# mutual read access: each user is in the other's group, homes are group-traversable
sudo usermod -aG perso wsl
sudo chmod 750 /home/wsl /home/perso

# passwordless sudo, like the default WSL user (no password is set for perso)
echo 'perso ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/perso-no-password >/dev/null
sudo chmod 440 /etc/sudoers.d/perso-no-password
sudo visudo -cq
```

Add `umask 022` to the `~/.zshenv` of both users so files stay readable, but not writable, by the other one. Files
created with mode `600`/`700` stay private, which is the case of `~/.ssh`, `~/.claude.json`,
`~/.claude/.credentials.json`, the `gh` and docker configs.

Then give `perso` its own git identity (`~/.gitconfig` with the personal email) and copy the shell setup if wanted (rc
files, oh-my-zsh, p10k, `~/.bash-dev-env`, rewriting `/home/wsl` paths to `/home/perso`).

## 4. The `wsl-default-user` script

Install it in `/usr/local/bin` so both users can run it:

```bash
sudo install -m 755 wsl-default-user /usr/local/bin/wsl-default-user
```

```bash
#!/usr/bin/env bash
# Show or change the default user of this WSL distro.
#
# Usage:
# wsl-default-user                  show the current default user
# wsl-default-user <user>           set it (takes effect at next distro start)
# wsl-default-user <user> --restart set it and terminate the distro now
# (closes every WSL session of this distro,
# VS Code included)
set -euo pipefail

readonly WSL_CONF=/etc/wsl.conf

currentDefaultUser() {
  sed -n '/^\[user\]/,/^\[/ s/^default[[:space:]]*=[[:space:]]*//p' "${WSL_CONF}"
}

runAsRoot() {
  if [[ ${EUID} -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

if [[ $# -eq 0 ]]; then
  echo "default user: $(currentDefaultUser)"
  exit 0
fi

newUser="$1"
restart="${2:-}"
if ! id "${newUser}" >/dev/null 2>&1; then
  echo "unknown user: ${newUser}" >&2
  exit 1
fi

if grep -q '^\[user\]' "${WSL_CONF}"; then
  if [[ -n "$(currentDefaultUser)" ]]; then
    runAsRoot sed -i "/^\[user\]/,/^\[/ s/^default[[:space:]]*=.*/default=${newUser}/" "${WSL_CONF}"
  else
    runAsRoot sed -i "/^\[user\]/a default=${newUser}" "${WSL_CONF}"
  fi
else
  printf '\n[user]\ndefault=%s\n' "${newUser}" | runAsRoot tee -a "${WSL_CONF}" >/dev/null
fi
echo "default user: $(currentDefaultUser)"

if [[ "${restart}" == "--restart" ]]; then
  distro="${WSL_DISTRO_NAME:?not running inside WSL}"
  echo "terminating ${distro}; reopen VS Code (or the terminal) to log in as ${newUser}"
  wsl.exe --terminate "${distro}"
else
  echo "takes effect after: wsl --terminate ${WSL_DISTRO_NAME:-<distro>} (from Windows)"
fi
```

Notes:

- the `sed` range `/^\[user\]/,/^\[/` only touches `default=` inside the `[user]` section;
- `wsl.exe --terminate` is called from inside the distro (WSL interop), using `WSL_DISTRO_NAME` that WSL exports in
  every session, so the script does not need to know the distro name;
- if the distro does not start anymore or you are outside it, the same can be done from PowerShell:
  `wsl -d Ubuntu2404 -u root wsl-default-user perso; wsl --terminate Ubuntu2404`.

## 5. The `switchToPersoUser` / `switchToWslUser` aliases

Both users source the same aliases file (Eg: `~/.zshrc`):

```bash
alias switchToPersoUser=$'wsl-default-user perso --restart'
alias switchToWslUser=$'wsl-default-user wsl --restart'
```

Daily usage, from any terminal of the distro (including the VS Code integrated terminal):

```bash
switchToPersoUser # VS Code is closed, reopen it: it is now connected as perso
switchToWslUser   # back to the pro account
wsl-default-user  # just show who the default user currently is
```

Reopen VS Code and use "WSL: Connect", or from PowerShell:

```powershell
code --remote wsl+Ubuntu2404 /home/perso/fchastanet/my-documents
```

{{% alert title="Warning" color="warning" %}} `--restart` terminates the whole distro: every WSL terminal, running
container (docker daemon inside WSL) and Claude Code session of **both** users is killed. Finish or commit ongoing work
first. {{% /alert %}}

## 6. Showing the default user in the prompt

Because the switch is effective only after a restart, it helps to see in the prompt which user VS Code will use. A
custom powerlevel10k segment (`~/.p10k.zsh`) reads `/etc/wsl.conf` and displays `wsl:<user>`, green when it is the
logged-in user, red otherwise (switch pending, or terminal opened as the other account):

```zsh
function prompt_wsl_default_user() {
  local conf=/etc/wsl.conf line section defaultUser
  [[ -r $conf ]] || return
  for line in "${(@f)$(<$conf)}"; do
    line=${line//[[:space:]]/}
    if [[ $line == \[*\] ]]; then
      section=$line
    elif [[ $section == '[user]' && $line == default=* ]]; then
      defaultUser=${line#default=}
    fi
  done
  [[ -n $defaultUser ]] || return
  if [[ $defaultUser == $USER ]]; then
    p10k segment -b 0 -f 2 -t "wsl:${defaultUser}"
  else
    p10k segment -b 0 -f 1 -t "wsl:${defaultUser}"
  fi
}
```

Then add `wsl_default_user` to `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` (or the right ones).

## 7. First login as perso

Once VS Code is connected as `perso`, in its integrated terminal:

```bash
# Claude Code CLI for this user, then /login with the personal account
curl -fsSL https://claude.ai/install.sh | bash
claude

# personal GitHub access
ssh-keygen -t ed25519 -C "perso@wsl" # add ~/.ssh/id_ed25519.pub to GitHub
gh auth login
```

VS Code extensions live in `~/.vscode-server`, so they are per user: install the Claude Code extension again (or copy
`~/.vscode-server/extensions` from `wsl`) and sign in with the personal account. VS Code profiles and settings stored on
the Windows side are shared by both users.

`~/.claude.json` is not copied on purpose: `perso` trusts each project folder again, and MCP servers are configured per
account.

## 8. Caveats

- **Isolation is against accidental mixing, not against an attacker**: both users have passwordless sudo and the docker
  group, which both give root.
- **Git "dubious ownership"**: running git as `wsl` in a repository owned by `perso` (or the reverse) is refused. Add
  `git config --global --add safe.directory /home/perso/fchastanet/<repo>` if really needed, or simply switch user.
- **Docker** is a single daemon: both users see the same containers, images and volumes.
- **Group-readable secrets**: with `750` homes, any `640`/`644` file is readable by the other user. Tighten files like
  `~/.aws/credentials`, `~/.kube/config` or project `.env` files with `chmod 600`.
- **Moved projects keep old sessions**: if repositories were moved from `/home/wsl` to `/home/perso`, the pro account
  still has their transcripts under `/home/wsl/.claude/projects/-home-wsl-...`; delete them once the personal side
  works.
