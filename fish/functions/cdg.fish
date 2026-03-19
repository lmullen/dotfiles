# cd into a GitHub repo by name under ~/github/<user>/<repo>
function cdg --description "cd into a GitHub repo by name"
    if test (count $argv) -ne 1
        echo "Usage: cdg <repo>" >&2
        return 1
    end

    set -l matches (find ~/github -mindepth 2 -maxdepth 2 -type d -name "$argv[1]")

    switch (count $matches)
        case 0
            echo "cdg: no repo named '$argv[1]'" >&2
            return 1
        case 1
            cd $matches[1]
        case '*'
            echo "cdg: multiple repos named '$argv[1]':" >&2
            for m in $matches
                echo "  $m" >&2
            end
            return 1
    end
end
