#!/usr/bin/env bash

# Tmux Sessionizer Script
# Author: Binoy Manoj
# https://github.com/binoymano

new_session=false
if [[ $1 == "new" ]]; then
    new_session=true
    shift  
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/ ~/.config ~/Bounty ~/Codes ~/Codes/* ~/CyberSec ~/Development ~/Documents ~/Downloads ~/Music ~/Obsidian ~/Pictures ~/Tools ~/Videos -mindepth 1 -maxdepth 1 -type d | \
        sed "s|^$HOME/||" | \
        fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --prompt="📁 " \
            --pointer="→" \
            --header="Select directory" \
            --preview="ls -la $HOME/{} | head -8" \
            --preview-window=right:45%:border-left \
            --color=fg:#cad3f5,hl:#ed8796,fg+:#cad3f5,hl+:#ed8796 \
            --color=border:#8087a2,header:#8087a2,prompt:#c6a0f6 \
            --color=pointer:#f4dbd6,marker:#f4dbd6,info:#c6a0f6 \
            --info=inline
    )
    # Add home path back
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
    while tmux has-session -t "$session_name" 2>/dev/null; do
        session_name="${selected_name}_${counter}"
        ((counter++))
    done
    
    tmux new-session -d -s "$session_name" -c "$selected"
    tmux switch-client -t "$session_name"
else
    tmux new-window -c "$selected" -n "$selected_name"
fi
