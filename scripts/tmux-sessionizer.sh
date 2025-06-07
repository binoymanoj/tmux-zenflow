#!/usr/bin/env bash

# Tmux Sessionizer Script
# Author: Binoy Manoj
# https://github.com/binoymanoj

new_session=false
if [[ $1 == "new" ]]; then
    new_session=true
    shift  
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Get search paths from tmux option or use defaults
    search_paths=$(tmux show-option -gqv "@zenflow-search-paths")
    if [[ -z "$search_paths" ]]; then
        search_paths="~/ ~/.config ~/Bounty ~/Codes ~/Codes/* ~/CyberSec ~/Development ~/Documents ~/Downloads ~/Music ~/Notes ~/Pictures ~/Tools ~/Videos"
    fi
    
    # Use eval to expand the paths properly
    selected=$(eval "find $search_paths -mindepth 1 -maxdepth 1 -type d 2>/dev/null" | \
        sed "s|^$HOME/||" | \
        fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --prompt="📁 " \
            --pointer="→" \
            --header="Select directory for $(if [[ $new_session == true ]]; then echo 'new session'; else echo 'new window'; fi)" \
            --preview="ls -a $HOME/{} 2>/dev/null | head -8" \
            --preview-window=right:45%:border-left \
            --color=fg:#cad3f5,hl:#ed8796,fg+:#cad3f5,hl+:#ed8796 \
            --color=border:#8087a2,header:#8087a2,prompt:#c6a0f6 \
            --color=pointer:#f4dbd6,marker:#f4dbd6,info:#c6a0f6 \
            --info=inline
    )
    # In --preview - instead of `ls -a` you can update it to `ls -la` if you want details of each folder, I like it this way
    
    # Add home path back if selection was made
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

# If not in tmux, start tmux first
if [[ -z $TMUX ]]; then
    tmux new-session -d -s main -c "$selected"
    tmux attach-session -t main
    exit 0
fi

if [[ $new_session == true ]]; then
    session_name="$selected_name"
    counter=1
    
    # Find unique session name
    while tmux has-session -t "$session_name" 2>/dev/null; do
        session_name="${selected_name}_${counter}"
        ((counter++))
    done
    
    tmux new-session -d -s "$session_name" -c "$selected"
    tmux switch-client -t "$session_name"
else
    # Check if window with same name exists and make it unique
    window_name="$selected_name"
    counter=1
    while tmux list-windows -F "#{window_name}" | grep -q "^${window_name}$" 2>/dev/null; do
        window_name="${selected_name}_${counter}"
        ((counter++))
    done
    
    tmux new-window -c "$selected" -n "$window_name"
fi
