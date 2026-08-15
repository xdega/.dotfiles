#!/usr/bin/env bash
#
# stow_link.sh — symlinks every package in this repo into $HOME with GNU
# Stow, backing up any pre-existing real files/directories that are in the
# way first (so the stow-managed version always wins).
#
# Usage:
#   scripts/stow_link.sh            # link/re-link all packages
#   scripts/stow_link.sh vim zsh    # link/re-link only the named packages
#   scripts/stow_link.sh -D         # unlink (remove symlinks) all packages
#
# Re-running this script is always safe: already-correct symlinks are left
# alone, and it's what you run after `git pull` to pick up changes too.
#
# Implementation note: this script deliberately pre-creates every directory
# a package needs as a *real* directory before calling stow, which forces
# Stow to link individual files rather than folding a whole directory into
# one symlink (e.g. `~/.pi -> dotfiles/pi/.pi`). Folding is normally a nice
# space-saving trick, but here several packages share a parent directory
# with files Stow doesn't manage (~/.pi/agent/auth.json, ~/.vim/plugged,
# oh-my-zsh's own framework files, ...) — if that parent got folded into a
# single symlink, anything later written there (auth tokens, installed
# plugins) would physically land inside this git repo, and a naive re-run
# of the backup step below could even `mv` real files *out of the repo*
# when walking through the fold. Pre-creating real directories avoids the
# whole class of problem.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}"
BACKUP_DIR="${DOTFILES_DIR}/.backup/$(date +%Y%m%d-%H%M%S)"
backed_up=0

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

MODE="restow"   # -R : safe default, handles both first-time link and re-sync
if [ "${1:-}" = "-D" ]; then
  MODE="D"
  shift
fi

# Packages are every top-level directory except dotfiles-repo plumbing.
if [ "$#" -gt 0 ]; then
  PACKAGES=("$@")
else
  PACKAGES=()
  for d in "$DOTFILES_DIR"/*/; do
    name="$(basename "$d")"
    case "$name" in
      scripts|.git|.backup) continue ;;
    esac
    PACKAGES+=("$name")
  done
fi

if [ "$MODE" = "D" ]; then
  info "Unlinking packages: ${PACKAGES[*]}"
  stow -v -D -d "$DOTFILES_DIR" -t "$TARGET" "${PACKAGES[@]}"
  exit 0
fi

# Ensure every path component from $TARGET down to (but not including) the
# leaf is a real directory, backing up anything currently in the way
# (typically a stray symlink from an earlier/foreign setup). A hidden
# `.stow-keep` marker is dropped in each one: an empty real directory isn't
# enough to stop Stow folding it back into a single symlink the moment it
# has nothing else to preserve, so the marker permanently guarantees these
# directories stay real, however empty they otherwise look.
ensure_real_dir() {
  local dir="$1" current="$TARGET" part rel_bkp
  local rel="${dir#"$TARGET"/}"
  [ "$dir" = "$TARGET" ] && return 0
  local oldIFS="$IFS"
  IFS='/'
  for part in $rel; do
    IFS="$oldIFS"
    current="$current/$part"
    if [ -L "$current" ]; then
      rel_bkp="${current#"$TARGET"/}"
      info "Replacing symlink with a real directory: $current"
      mkdir -p "$(dirname "$BACKUP_DIR/$rel_bkp")"
      mv "$current" "$BACKUP_DIR/$rel_bkp"
      backed_up=1
    fi
    [ -d "$current" ] || mkdir -p "$current"
    [ -e "$current/.stow-keep" ] || : > "$current/.stow-keep"
    IFS='/'
  done
  IFS="$oldIFS"
}

# --- Pre-create real directories, then back up any real conflicting files --
for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$DOTFILES_DIR/$pkg"
  [ -d "$pkg_dir" ] || continue
  while IFS= read -r -d '' src_file; do
    rel_path="${src_file#"$pkg_dir"/}"
    target_path="$TARGET/$rel_path"

    ensure_real_dir "$(dirname "$target_path")"

    if [ -e "$target_path" ] && [ "$target_path" -ef "$src_file" ]; then
      continue   # already correctly linked to this exact file, nothing to do
    fi

    if [ -L "$target_path" ]; then
      info "Removing symlink that doesn't point into this repo: $target_path"
      rm "$target_path"
    elif [ -e "$target_path" ]; then
      info "Backing up existing $target_path"
      mkdir -p "$(dirname "$BACKUP_DIR/$rel_path")"
      mv "$target_path" "$BACKUP_DIR/$rel_path"
      backed_up=1
    fi
  done < <(find "$pkg_dir" -type f -print0)
done

if [ "$backed_up" = 1 ]; then
  info "Existing dotfiles that were replaced are saved under: $BACKUP_DIR"
fi

# --- Stow ---------------------------------------------------------------
info "Stowing packages: ${PACKAGES[*]}"
stow -v -R -d "$DOTFILES_DIR" -t "$TARGET" "${PACKAGES[@]}"

info "Done. Run 'stow -d \"$DOTFILES_DIR\" -t \"$TARGET\" -n -v <package>' any time to preview changes without applying them."
