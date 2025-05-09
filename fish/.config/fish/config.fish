source /usr/share/cachyos-fish-config/cachyos-config.fish
source ~/.config/fish/aliases.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Start Starship prompt
starship init fish | source
