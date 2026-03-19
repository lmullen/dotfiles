# Completions for cdg: repo names under ~/github/<user>/<repo>
complete -c cdg -f -a '(for dir in ~/github/*/*/; basename $dir; end)'
