# Shows a list of the largest files in a directory and its subdirectories
# Run as 
# large_files
# or
# large_files -n 20
function large_files
    argparse 'n=!_validate_int' -- $argv
    set -q _flag_n; or set _flag_n 10
    find . -type f -exec du -h {} + | sort -rh | head -$_flag_n
end
