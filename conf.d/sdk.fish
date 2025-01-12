# Check if the SDKMAN_DIR environment variable is not already set

if not set -q SDKMAN_DIR
    # Check if the default SDKMAN directory exists in $HOME/.sdkman
    if test -d "$HOME/.sdkman"
        set -gx SDKMAN_DIR "$HOME/.sdkman"
    else
        # Check if Homebrew SDKMAN directory exists
        set brew_sdkman_dir (brew --prefix sdkman-cli 2>/dev/null)/libexec
        if test -d $brew_sdkman_dir
            set -gx SDKMAN_DIR $brew_sdkman_dir
        else
            # Print an error message if no SDKMAN installation is found
            echo (set_color red)"Error:"(set_color normal) "SDKMAN does not appear to be installed in a standard location."
            echo "Please verify SDKMAN has been installed to $HOME/.sdkman or via brew and/or set the SDKMAN_DIR environment variable manually."
        end
    end
end
