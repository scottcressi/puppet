#!/usr/bin/env sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! command -v r10k > /dev/null ; then echo r10k gem is not installed ;  exit 0 ; fi
if ! command -v puppet > /dev/null ; then echo puppet gem is not installed ;  exit 0 ; fi
if ! command -v yamllint > /dev/null ; then echo yamllimt is not installed ;  exit 0 ; fi

cd "$DIR"/../ && yamllint -s -d "{extends: default, rules: {line-length: {max: 999}}}" data
cd "$DIR"/../ && r10k puppetfile check
cd "$DIR"/../ && r10k puppetfile install --color --verbose info --force --moduledir modules_forge
cd "$DIR"/../ && puppet module list --modulepath modules_forge --tree
cd "$DIR"/../ && find manifests modules -type f | grep "\\.pp" | xargs puppet parser validate
