#
# Completion trigger predicates
#

# Test if there is no command
function __fish_sdkman_no_command
    set cmd (commandline -opc)
    if test (count $cmd) -eq 1
        return 0
    end
    return 1
end

# Test if the main command matches one of the parameters
function __fish_sdkman_using_command
    set cmd (commandline -opc)
    if test (count $cmd) -eq 2; and contains $cmd[2] $argv
        return 0
    end
    return 1
end

# Test if the main command matches one of the parameters and the candidate is specified
function __fish_sdkman_specifying_candidate
    set cmd (commandline -opc)
    if test (count $cmd) -eq 3; and contains $cmd[2] $argv
        return 0
    end
    return 1
end

# Test if the command has enough parameters
function __fish_sdkman_command_has_enough_parameters
    set cmd (commandline -opc)
    if test (count $cmd) -ge (math $argv[1] + 2); and contains $cmd[2] $argv[2..-1]
        return 0
    end
    return 1
end

#
# Data collectors
#

# Fetch the list of candidates
function __fish_sdkman_candidates
    string split ',' < "$SDKMAN_DIR/var/candidates"
end

# Fetch the list of versions for the given candidate
function __fish_sdkman_candidate_versions
    set cmd (commandline -opc)
    if test (count $cmd) -eq 3
        set candidate $cmd[3]
        set sdkman_api "$SDKMAN_CANDIDATES_API/candidates/$candidate/$SDKMAN_PLATFORM/versions/all"
        curl --silent $sdkman_api | string split ','
    end
end

# Fetch the list of installed versions for the given candidate
function __fish_sdkman_candidates_with_versions
    find "$SDKMAN_DIR/candidates/" -mindepth 2 -maxdepth 2 -name '*current' \
        | awk -F / '{ print $(NF-1) }' \
        | sort -u
end

# Fetch the list of installed versions for the given candidate
function __fish_sdkman_installed_versions
    set cmd (commandline -opc)
    if test -d "$SDKMAN_DIR/candidates/$cmd[3]/current"
        ls -1 "$SDKMAN_DIR/candidates/$cmd[3]" | grep -v 'current'
    end
end

#
# Completion specification
#

# No command
complete -c sdk -f -n __fish_sdkman_no_command -a 'c current' -d 'Display current version'
complete -c sdk -f -n __fish_sdkman_no_command -a 'd default' -d 'Set default version'
complete -c sdk -f -n __fish_sdkman_no_command -a 'e env' -d 'Load environment from .sdkmanrc file'
complete -c sdk -f -n __fish_sdkman_no_command -a 'h home' -d 'Show installation folder of given candidate'
complete -c sdk -f -n __fish_sdkman_no_command -a 'i install' -d 'Install new version'
complete -c sdk -f -n __fish_sdkman_no_command -a 'ls list' -d 'List versions'
complete -c sdk -f -n __fish_sdkman_no_command -a 'rm uninstall' -d 'Uninstall version'
complete -c sdk -f -n __fish_sdkman_no_command -a 'u use' -d 'Use specific version'
complete -c sdk -f -n __fish_sdkman_no_command -a 'ug upgrade' -d 'Display what is outdated'
complete -c sdk -f -n __fish_sdkman_no_command -a 'v version' -d 'Display version'
complete -c sdk -f -n __fish_sdkman_no_command -a help -d 'Display help message'
complete -c sdk -f -n __fish_sdkman_no_command -a offline -d 'Set offline status'
complete -c sdk -f -n __fish_sdkman_no_command -a selfupdate -d 'Update sdk'
complete -c sdk -f -n __fish_sdkman_no_command -a update -d 'Reload the candidate list'

# install
# Suggest candidates as the second argument
complete -c sdk -f -n '__fish_sdkman_using_command i install' -a "(__fish_sdkman_candidates)"
# Suggest available versions for the given candidate
complete -c sdk -f -n '__fish_sdkman_specifying_candidate i install' -a "(__fish_sdkman_candidate_versions)"

# uninstall
complete -c sdk -f -n '__fish_sdkman_using_command rm uninstall' -a "(__fish_sdkman_candidates_with_versions)"
complete -c sdk -f -n '__fish_sdkman_specifying_candidate rm uninstall' -a "(__fish_sdkman_installed_versions)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 2 rm uninstall'

# list
complete -c sdk -f -n '__fish_sdkman_using_command ls list' -a "(__fish_sdkman_candidates)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 ls list'

# use
complete -c sdk -f -n '__fish_sdkman_using_command u use' -a "(__fish_sdkman_candidates_with_versions)"
complete -c sdk -f -n '__fish_sdkman_specifying_candidate u use' -a "(__fish_sdkman_installed_versions)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 2 u use'

# default
complete -c sdk -f -n '__fish_sdkman_using_command d default' -a "(__fish_sdkman_candidates_with_versions)"
complete -c sdk -f -n '__fish_sdkman_specifying_candidate d default' -a "(__fish_sdkman_installed_versions)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 2 d default'

# current
complete -c sdk -f -n '__fish_sdkman_using_command c current' -a "(__fish_sdkman_candidates)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 c current'

# upgrade
complete -c sdk -f -n '__fish_sdkman_using_command ug upgrade' -a "(__fish_sdkman_candidates_with_versions)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 ug upgrade'

# version
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 0 v version'

# help
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 0 h help'

# offline
complete -c sdk -f -n '__fish_sdkman_using_command offline' -a enable -d 'Make sdk work while offline'
complete -c sdk -f -n '__fish_sdkman_using_command offline' -a disable -d 'Turn on all features'
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 offline'

# selfupdate
complete -c sdk -f -n '__fish_sdkman_using_command selfupdate' -a force -d 'Force re-install of current version'
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 selfupdate'

# update
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 0 update'

# flush
complete -c sdk -f -n '__fish_sdkman_using_command flush' -a temp -d 'Clear out staging work folder'
complete -c sdk -f -n '__fish_sdkman_using_command flush' -a version -d 'Flush version file'
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 flush'

# env
complete -c sdk -f -n '__fish_sdkman_using_command e env' -a init -d 'Initialize .sdkmanrc file'
complete -c sdk -f -n '__fish_sdkman_using_command e env' -a install -d 'Install all candidate versions listed in .sdkmanrc'
complete -c sdk -f -n '__fish_sdkman_using_command e env' -a clear -d 'Unload currently loaded environment'
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 1 e env'

# home
complete -c sdk -f -n '__fish_sdkman_using_command h home' -a "(__fish_sdkman_candidates_with_versions)"
complete -c sdk -f -n '__fish_sdkman_specifying_candidate h home' -a "(__fish_sdkman_installed_versions)"
complete -c sdk -f -n '__fish_sdkman_command_has_enough_parameters 2 h home'
