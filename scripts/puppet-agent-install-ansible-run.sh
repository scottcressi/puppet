#!/usr/bin/env bash

if [ -z "$1" ] ; then echo enter host group && exit 1 ; fi
if ! command -v ansible ; then echo ansible is not installed ;  exit 0 ; fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook \
    -i "$DIR"/puppet-agent-install-ansible-hosts.txt \
    "$DIR"/puppet-agent-install-ansible-playbook.yaml \
    --limit "$1"
