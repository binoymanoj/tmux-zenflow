#!/usr/bin/env bash

# Open PDFs script
# Author: Binoy Manoj
# GitHub: https://github.com/binoymanoj/tmux-zenflow

# Get user-defined PDF paths or use defaults
pdf_paths=$(tmux show-option -gqv "@zenflow-pdf-paths")
if [[ -z "$pdf_paths" ]]; then
    # Default PDF search paths
    pdf_paths="~/CyberSec/Books ~/Documents/Books ~/Development/Books ~/Downloads"
fi

# Get user-defined PDF viewer or use default
pdf_viewer=$(tmux show-option -gqv "@zenflow-pdf-viewer")
pdf_viewer=${pdf_viewer:-"zathura"}

# If a PDF file is provided as argument, use it
if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Get current pane directory
    current_dir=$(tmux run "echo #{pane_current_path}")
    
    # Build find command with user-defined paths plus current directory
    find_cmd="$current_dir"
    for path in $pdf_paths; do
        # Expand tilde to home directory
        expanded_path=$(eval echo "$path")
        if [[ -d "$expanded_path" ]]; then
            find_cmd="$find_cmd $expanded_path"
        fi
    done
    
    # Execute find command and pipe to fzf
    selected=$(eval "find $find_cmd -mindepth 1 -maxdepth 1 -name \"*.pdf\" 2>/dev/null" | \
        sed "s|^$HOME/||" | \
        fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --prompt="📚 " \
            --pointer="→" \
            --header="Select PDF to open" \
            --preview="pdfinfo \$HOME/{} 2>/dev/null || echo 'PDF info not available'" \
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

# Exit if no selection was made
if [[ -z "$selected" ]]; then
    exit 1
fi

# Get window name from PDF filename
selected_name=$(basename "$selected" | tr . _)

# Open PDF in new tmux window
tmux new-window -n "$selected_name" -d "$pdf_viewer" "$selected"
tmux select-window -l
