#!/bin/bash

# Returns "true" if running under GNOME (Wayland or X11), otherwise "false"
is_gnome() {
  # GNOME on Wayland
  if [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ] || [ "${DESKTOP_SESSION:-}" = "gnome" ]; then
    return 0
  fi

  # GNOME on X11 (common cases)
  if [ "${XDG_SESSION_DESKTOP:-}" = "gnome" ] || [ "${DESKTOP_SESSION:-}" = "gnome" ]; then
    return 0
  fi

  # Fallback: check gnome-shell process
  if command -v pgrep >/dev/null 2>&1 && pgrep -x gnome-shell >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

