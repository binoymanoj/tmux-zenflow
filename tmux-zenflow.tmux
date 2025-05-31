CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  && pwd )"
tmux bind-key z run-shell "$CURRENT_DIR/scripts/tmux-sessionizer.sh"
tmux bind-key Z run-shell "$CURRENT_DIR/scripts/tmux-sessionizer.sh new"
tmux bind-key q run-shell "$CURRENT_DIR/scripts/open-pdf.sh"
