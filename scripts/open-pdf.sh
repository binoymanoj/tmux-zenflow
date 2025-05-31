#!/usr/bin/env bash

# Open PDF Script
# Author: Binoy Manoj
# https://github.com/binoymanoj

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Get PDF search paths from tmux option or use defaults
    pdf_paths=$(tmux show-option -gqv "@zenflow-pdf-paths")
    if [[ -z "$pdf_paths" ]]; then
        # Get current pane path
        current_path=$(tmux display-message -p "#{pane_current_path}")
        pdf_paths="$current_path ~/CyberSec/Books ~/Documents/Books ~/Development/Books"
    fi
    
    # Use eval to expand paths and find PDFs
    selected=$(eval "find $pdf_paths -mindepth 1 -maxdepth 1 -name '*.pdf' 2>/dev/null" | \
        sed "s|^$HOME/||" | \
        fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --prompt="📚 " \
            --pointer="→" \
            --header="Select PDF to open" \
            --preview="pdfinfo $HOME/{} 2>/dev/null || echo 'PDF info not available'" \
            --preview-window=right:45%:border-left \
            --color=fg:#cad3f5,hl:#ed8796,fg+:#cad3f5,hl+:#ed8796 \
            --color=border:#8087a2,header:#8087a2,prompt:#c6a0f6 \
            --color=pointer:#f4dbd6,marker:#f4dbd6,info:#c6a0f6 \
            --info=inline
    )
    
    # Add home path back if selection was made
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

if [[ -z "$selected" ]]; then
    exit 1
fi

selected_name=$(basename "$selected" | tr . _)

# Get PDF viewer from tmux option or use default
pdf_viewer=$(tmux show-option -gqv "@zenflow-pdf-viewer")
pdf_viewer=${pdf_viewer:-"zathura"}

# Check if we're in tmux
if [[ -n $TMUX ]]; then
    # Create new window for PDF viewer
    window_name="$selected_name"
    counter=1
    
    # Find unique window name
    while tmux list-windows -F "#{window_name}" | grep -q "^${window_name}$" 2>/dev/null; do
        window_name="${selected_name}_${counter}"
        ((counter++))
    done
    
    tmux new-window -n "$window_name" -d "$pdf_viewer '$selected'"
    tmux select-window -l  # Go back to last window
else
    # If not in tmux, just open the PDF
    "$pdf_viewer" "$selected" &
fi
