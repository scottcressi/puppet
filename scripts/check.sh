#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! command -v r10k ; then echo r10k gem is not installed ;  exit 0 ; fi
if ! command -v puppet ; then echo puppet gem is not installed ;  exit 0 ; fi
if ! command -v yamllint ; then echo yamllimt is not installed ;  exit 0 ; fi

cd $DIR/../ && yamllint -s -d "{extends: default, rules: {line-length: {max: 999}}}" data
cd $DIR/../ && r10k puppetfile check
cd $DIR/../ && r10k puppetfile install --color --verbose info --force --moduledir modules_forge
cd $DIR/../ && puppet module list --modulepath modules_forge --tree