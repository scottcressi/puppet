#r10k deploy environment --verbose
yamllint -s -d "{extends: default, rules: {line-length: {max: 999}}}" data
r10k puppetfile check
r10k puppetfile install --color --verbose notice --force --moduledir modules_forge
puppet module list --modulepath modules_forge --tree
