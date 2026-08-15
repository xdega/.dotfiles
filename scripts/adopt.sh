#!/usr/bin/env bash
#
# adopt.sh — pulls a file that a tool wrote directly into $HOME (bypassing
# Stow entirely) into this repo, and leaves a symlink in its place. This is
# the reverse of the usual conflict: normally *you* have a real file and
# Stow wants to replace it; here the real file already has the content you
# want to keep, and you want the repo to adopt it.
#
# Usage:
#   scripts/adopt.sh <package> <path-relative-to-home> [path-relative-to-home ...]
#
# Examples:
#   scripts/adopt.sh warp .warp/themes/my-custom-theme.yaml
#   scripts/adopt.sh pi .pi/agent/settings.json
#   scripts/adopt.sh zsh .oh-my-zsh/custom/aliases.zsh
#
# <package> is an existing top-level package directory in this repo (vim,
# zsh, warp, pi, git, ...) or a new name — pass a package that doesn't exist
# yet and it's created for you, so this also works for a brand new tool.
#
# What it does:
#   1. Creates an (empty) placeholder for the path inside the package, if
#      one doesn't already exist there.
#   2. Runs `stow --adopt`, which moves the real file's *content* into that
#      placeholder and replaces the real file with a symlink to it.
#   3. Re-runs scripts/stow_link.sh so the same folding-prevention
#      guarantees (.stow-keep markers, etc.) apply going forward.
#
# After running, review what got pulled in with `git diff` before
# committing — --adopt takes whatever is currently on disk, which is
# usually what you want here, but it's still worth a look.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

if [ "$#" -lt 2 ]; then
  echo "Usage: $(basename "$0") <package> <path-relative-to-home> [more paths...]" >&2
  exit 1
fi

PKG="$1"; shift
PKG_DIR="$DOTFILES_DIR/$PKG"
mkdir -p "$PKG_DIR"

for REL in "$@"; do
  REL="${REL#/}"          # tolerate a leading slash
  REL="${REL#"$HOME"/}"   # tolerate a full $HOME-prefixed path too
  SRC="$TARGET/$REL"
  DEST="$PKG_DIR/$REL"

  if [ -L "$SRC" ]; then
    info "Skipping $REL — already a symlink (nothing to adopt)."
    continue
  fi
  if [ ! -e "$SRC" ]; then
    info "Skipping $REL — no such file in \$HOME."
    continue
  fi
  if [ -e "$DEST" ]; then
    info "Skipping $REL — $PKG/$REL already exists in the repo. Resolve manually."
    continue
  fi

  info "Adopting ~/$REL into $PKG/$REL"
  mkdir -p "$(dirname "$DEST")"
  if [ -d "$SRC" ]; then
    mkdir -p "$DEST"
  else
    : > "$DEST"
  fi
  # Plain `stow --adopt` (not `-R`) — combining --adopt with restow aborts
  # with a spurious conflict warning in current GNU Stow versions.
  stow --adopt -v -d "$DOTFILES_DIR" -t "$TARGET" "$PKG"
done

# Re-apply the same folding-prevention/backup guarantees the rest of the
# repo relies on, now that the adopted file(s) are in place.
"$DOTFILES_DIR/scripts/stow_link.sh" "$PKG"

info "Done. Review with: git -C \"$DOTFILES_DIR\" diff -- \"$PKG\", then commit when you're happy."
