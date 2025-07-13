#!/usr/bin/env bash

# Tmux Sessionizer - open new windows/sessions
# Author: Binoy Manoj
# GitHub: https://github.com/binoymanoj/tmux-zenflow

# Parse command line arguments
new_session=false
if [[ $1 == "new" ]]; then
    new_session=true
    shift  
fi

# Get user-defined search paths or use defaults
search_paths=$(tmux show-option -gqv "@zenflow-search-paths")
if [[ -z "$search_paths" ]]; then
    # Default search paths
    search_paths="~/ ~/.config ~/Bounty ~/Codes ~/Codes/* ~/CyberSec ~/Development ~/Documents ~/Downloads ~/Music ~/Notes ~/Pictures ~/Tools ~/Videos"
fi

# If a directory is provided as argument, use it
if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Build find command with user-defined paths
    find_cmd=""
    for path in $search_paths; do
        # Expand tilde to home directory
        expanded_path=$(eval echo "$path")
        if [[ -d "$expanded_path" ]]; then
            find_cmd="$find_cmd $expanded_path"
        fi
    done
    
    # Execute find command and pipe to fzf
    selected=$(eval "find $find_cmd -mindepth 1 -maxdepth 1 -type d 2>/dev/null" | \
        sed "s|^$HOME/||" | \
        fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --prompt="📁 " \
            --pointer="→" \
            --header="Select directory" \
            --preview="ls -a \$HOME/{} 2>/dev/null | head -8" \
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
if [[ -z $selected ]]; then
    exit 0
fi

# Get session/window name from directory
selected_name=$(basename "$selected" | tr . _)

# If not in tmux, start tmux first
if [[ -z $TMUX ]]; then
    tmux new-session -d -s main -c "$selected"
    tmux attach-session -t main
    exit 0
fi

# Handle session creation or window creation
if [[ $new_session == true ]]; then
    # Create new session with unique name
    session_name="$selected_name"
    counter=1
    while tmux has-session -t "$session_name" 2>/dev/null; do
        session_name="${selected_name}_${counter}"
        ((counter++))
    done
    
    tmux new-session -d -s "$session_name" -c "$selected"
    tmux switch-client -t "$session_name"
else
    # Create new window in current session
    tmux new-window -c "$selected" -n "$selected_name"
fi
