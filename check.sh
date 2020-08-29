#!/usr/bin/env bash

if ! command -v r10k ; then echo r10k gem is not installed ;  exit 0 ; fi
if ! command -v puppet ; then echo puppet gem is not installed ;  exit 0 ; fi
if ! command -v yamllint ; then echo yamllimt is not installed ;  exit 0 ; fi

yamllint -s -d "{extends: default, rules: {line-length: {max: 999}}}" data
r10k puppetfile check
r10k puppetfile install --color --verbose info --force --moduledir modules_forge
puppet module list --modulepath modules_forge --tree
