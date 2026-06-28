#!/bin/sh

# --- ZSH // History ---
# Guide: https://github.com/rothgar/mastering-zsh/blob/master/docs/config/history.md

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# --- ZSH // Behaviour ---

setopt NUMERIC_GLOB_SORT

# Initialize completion
autoload -U compinit; compinit

# --- UTILITY :: Terminal Multiplexer // alias // Herder ---

if command -v herdr &>/dev/null; then
    alias h="herdr"
else
    echo "!ERROR! - herdr is not installed, please install it."
fi

# --- UTILITY :: Find // Init, alias, and command exports // Fuzzy Finder ---
source <(fzf --zsh)

if command -v fzf &>/dev/null; then
    alias f="fzf"
    alias ff="fzf 
        --preview 'bat --style=numbers --color=always --line-range=:500 {}'"
    export FZF_CTRL_T_OPTS="
        --preview 'bat --style=numbers --color=always --line-range=:500 {}'"
else
    echo "!ERROR! - fzf is not installed, please install it."
fi

# --- UTILITY :: CD // Init and Aliasing // Zoxide ---
eval "$(zoxide init zsh)"

if command -V zoxide &>/dev/null; then
    alias cd='z'
    alias cdi='zi'
else
    echo "!ERROR! - zoxide is not installed, please install it."
fi

# --- UTILITY :: Listing Files // Aliasing // Eza ---
if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -l --header --icons'
    alias la='eza -lah --git  --header --icons --group-directories-first'
    alias lh='eza -lAd .* --header --icons'
    alias tree='eza -aTli --git'
else
    echo "!ERROR! - eza is not installed, please install it."
fi

# --- UTILITY :: TODO Function // Aliasing // Tuxedo ---
if command -v tuxedo &>/dev/null; then
    TODO_DIR="$HOME/.config/tuxedo"
    TODO_FILE="$TODO_DIR/todo.txt"
    DONE_FILE="$TODO_DIR/done.txt"
    alias tdl="tuxedo $TODO_FILE"
    alias tda="tuxedo add"
else
    echo "!ERROR! - Tuxedo task manager is not installed, please install it."
fi

# --- CODE :: SCM // Aliasing // GIT ---

if command -v git &>/dev/null; then
    alias gs="git status"
    alias ga="git add"
    alias gaa="git add --all"
    alias gua="git restore --staged ."
  
    alias gco="git checkout"
    alias gcb="git checkout -b"

    alias gcm="git commit -m"
    alias gca="git commit --amend --no-edit"
    alias gd="git diff"

    # Branch Management
    alias gb="git branch"
    alias gba="git branch -a"
    alias gbd="git branch -d"
    alias gbD="git branch -D"

    # Push & Pull
    alias gpl="git pull"
    alias gph="git push"
    alias gpsup="git push --set-upstream origin \$(git symbolic-ref --short HEAD)"

    # History & Logging
    alias glo="git log --oneline --graph --decorate"
    alias glg="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
else
    echo "!ERROR! - git is not installed, please install it."
fi

# --- THEME // Init // starship ---
eval "$(starship init zsh)"


# --- FUNCTIONS ---

# Display and filter all shell aliases cleanly (Mac & Linux)
zshelp() {
    echo -e "\033[1;35m=== Available Shell Shortcuts ===\033[0m"
    
    # 1. Grab live Zsh aliases
    # 2. Use awk to cleanly split by the FIRST equals sign only
    # 3. Strip out wrapping quotes safely
    local alias_list
    alias_list=$(alias | awk '
    {
        # Find the position of the first "="
        eq = index($0, "=")
        if (eq > 0) {
            name = substr($0, 1, eq - 1)
            cmd = substr($0, eq + 1)
            
            # Remove leading and trailing single/double quotes if they exist
            gsub(/^["'\''"]|["'\''"]$/, "", cmd)
            
            # Format nicely with a left-aligned 12-character spacing column
            printf "  \033[1;32m%-12s\033[0m \033[0;36m->\033[0m %s\n", name, cmd
        }
    }' | sort)

    if [ -n "$1" ]; then
        echo -e "\033[0;33mFiltering for: $1\033[0m"
        echo "$alias_list" | grep --color=always -i "$1"
    else
        echo "$alias_list"
    fi
    
    echo -e "\033[1;35m=================================\033[0m"
}

# Explains the system path and its contents. Much better than echoing a raw $PATH.
expath() {
    # 1. Set default sample size to 5 if no argument is provided
    local limit=${1:-5}

    # 2. Print the entire raw PATH with blue separators
    echo -e "\033[1;36m=== Current System PATH ===\033[0m"
    echo -e "${PATH//:/\033[1;34m:\033[0m}"
    echo -e "\033[1;36m===========================\033[0m"

    # 3. Loop through individual directories
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        # Skip empty entries if they occur
        [[ -z "$dir" ]] && continue

        if [[ -d "$dir" ]]; then
            echo -e "\n\033[1;32m[+] $dir\033[0m"
            
            # Fetch human-readable disk usage size safely
            local size
            size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
            echo "   Directory size:   $size"
            
            # Zsh Trick: (N-*) checks for executable files and handles empty dirs natively
            local execs=("$dir"/*(N-*))
            
            # Count only the filtered executables
            local count=${#execs[@]}
            echo "   Executable count: $count"
            
            # Preview the user-defined number of true commands
            if (( count > 0 )); then
                echo "   Sample binaries (showing up to $limit):"
                # Print onsly the filename, not the full path
                printf '%s\n' "${execs[@]:t}" | head -n "$limit" | sed 's/^/    |-> /'
            else
                echo "   Sample binaries:  (No executable commands found)"
            fi
        else
            echo -e "\n\033[1;31m[-] $dir (Broken Path)\033[0m"
        fi
    done
}

# Open the current remote Git repository in the default web browser
gopen() {
    # 1. Ensure we are inside a valid git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo -e "\033[0;31mError: Not a git repository (or any of the parent directories)\033[0m"
        return 1
    fi

    # 2. Extract the remote origin URL safely
    local url
    url=$(git remote get-url origin 2>/dev/null)

    if [ -z "$url" ]; then
        echo -e "\033[0;31mError: No remote 'origin' configured for this repository.\033[0m"
        return 1
    fi

    # 3. Clean and convert the URL (Handles SSH formats, removes trailing .git)
    url=$(echo "$url" | sed -E -e 's/^git@([^:]+):/https:\/\/\1\//' -e 's/\.git$//')

    echo -e "\033[0;32mOpening remote repository:\033[0m $url"

    # 4. Open based on your operating system (macOS vs Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url"
    else
        xdg-open "$url" &>/dev/null
    fi
}

# 1. AGGREGATED PROCESS TRACKER WITH NUMERICAL IDS
memtop() {
    local limit=${1:-10}
    echo -e "\033[1;35m=== Top $limit Memory Consuming Applications (Aggregated) ===\033[0m"
    echo -e "  \033[1;32m%-4s %-10s %-25s\033[0m" "ID" "TOTAL MEM" "APPLICATION"
    echo -e "  \033[0;36m-----------------------------------------------\033[0m"

    local ps_cmd="ps -ax -o rss,comm"
    [[ "$OSTYPE" != "darwin"* ]] && ps_cmd="ps -ax -o rss,args"

    # Capture, aggregate, and sort by RAM footprint
    eval "$ps_cmd" | awk 'NR>1 {
        cmd = $2; for(i=3; i<=NF; i++) cmd = cmd " " $i; sub(/.*\//, "", cmd)
        sub(/ Helper \(Alerts\)/, "", cmd); sub(/ Helper/, "", cmd); sub(/ --.*/, "", cmd)
        mem[cmd] += $1 / 1024
    }
    END {
        for (c in mem) {
            if (mem[c] >= 1024) {
                printf "%010.2f GB\t%s\n", mem[c] / 1024, c
            } else {
                printf "%010.0f MB\t%s\n", mem[c], c
            }
        }
    }' | sort -rh | head -n "$limit" | awk -F'\t' 'BEGIN {count=1} {
        printf "  \033[1;33m[%d]\033[0m  %-10s %-25s\n", count, $1, $2
        count++
    }'

    echo -e "\033[1;35m===============================================================\033[0m"
    echo -e "💡 Tip: Run \033[1;32mmemstop <name>\033[0m or just \033[1;32mmemstop\033[0m for an interactive menu."
}

# 2. INTUITIVE APPLICATION KILL SWITCH
memstop() {
    # Scenario A: User passed a specific application name string directly
    if [ -n "$1" ]; then
        local app_name="$1"
        echo -e "\033[1;31mTerminating all background processes matching: '$app_name'...\033[0m"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            pkill -f "$app_name"
        else
            pkill -f -i "$app_name"
        fi
        echo -e "\033[1;32m✓ Termination signals sent.\033[0m"
        return 0
    fi

    # Scenario B: Interactive Menu Mode (No parameters passed)
    echo -e "\033[1;35m=== Interactive Memory Kill Menu ===\033[0m"
    
    local ps_cmd="ps -ax -o rss,comm"
    [[ "$OSTYPE" != "darwin"* ]] && ps_cmd="ps -ax -o rss,args"

    # Re-generate the top 15 list dynamically into a temporary indexed bash array
    local apps=()
    while IFS=$'\t' read -r mem_val name; do
        apps+=("$name")
        # Format a quick console print string for the menu select interface
        echo -e "  \033[1;33m[${#apps[@]}]\033[0m \033[1;32m$mem_val\033[0m -> $name"
    done < <(eval "$ps_cmd" | awk 'NR>1 {
        cmd = $2; for(i=3; i<=NF; i++) cmd = cmd " " $i; sub(/.*\//, "", cmd)
        sub(/ Helper \(Alerts\)/, "", cmd); sub(/ Helper/, "", cmd); sub(/ --.*/, "", cmd)
        mem[cmd] += $1 / 1024
    }
    END {
        for (c in mem) {
            if (mem[c] >= 1024) printf "%010.2f GB\t%s\n", mem[c] / 1024, c
            else printf "%010.0f MB\t%s\n", mem[c], c
        }
    }' | sort -rh | head -n 15)

    echo -e "  \033[1;31m[q]\033[0m  Quit menu"
    echo -e "\033[1;35m====================================\033[0m"
    
    # Prompt the user for an ID index selection
    echo -n "Enter the number of the app you want to kill: "
    read -r choice

    if [[ "$choice" == "q" || -z "$choice" ]]; then
        echo "Cancelled."
        return 0
    fi

    # Validate that the user input is a valid list item index number
    if [[ "$choice" -gt 0 && "$choice" -le "${#apps[@]}" ]]; then
        local selected_app="${apps[$choice]}"
        echo -e "\033[1;31mKilling all instances of '$selected_app'...\033[0m"
        pkill -f "$selected_app"
        echo -e "\033[1;32m✓ Done. Re-run memtop to check freed RAM.\033[0m"
    else
        echo -e "\033[0;31mInvalid selection.\033[0m"
    fi
}
