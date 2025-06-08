#!/usr/bin/env bash
# Tmux Zenflow Plugin
# Author: Binoy Manoj

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default key bindings - users can override these
default_sessionizer_key="@zenflow-sessionizer-key"
default_new_session_key="@zenflow-new-session-key" 
default_pdf_key="@zenflow-pdf-key"

# Get user-defined keys or use defaults
sessionizer_key=$(tmux show-option -gqv "$default_sessionizer_key")
sessionizer_key=${sessionizer_key:-"f"}

new_session_key=$(tmux show-option -gqv "$default_new_session_key")
new_session_key=${new_session_key:-"F"}

pdf_key=$(tmux show-option -gqv "$default_pdf_key")
pdf_key=${pdf_key:-"o"}

# Default popup dimensions - users can override
popup_width=$(tmux show-option -gqv "@zenflow-popup-width")
popup_width=${popup_width:-"60%"}

popup_height=$(tmux show-option -gqv "@zenflow-popup-height")
popup_height=${popup_height:-"60%"}

# Bind keys with popup functionality
tmux bind-key "$sessionizer_key" display-popup -E -w "$popup_width" -h "$popup_height" "'$CURRENT_DIR/scripts/tmux-sessionizer.sh'"

tmux bind-key "$new_session_key" display-popup -E -w "$popup_width" -h "$popup_height" "'$CURRENT_DIR/scripts/tmux-sessionizer.sh' new"

tmux bind-key "$pdf_key" display-popup -E -w "$popup_width" -h "$popup_height" -x C -y C "'$CURRENT_DIR/scripts/tmux-open-pdf.sh'"
