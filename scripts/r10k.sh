DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

r10k deploy environment -c $DIR/../r10k.yaml --verbose
