docker run --rm -v $PWD:/yaml sdesbure/yamllint yamllint -s -d "{extends: default, rules: {line-length: {max: 999}}}" .
