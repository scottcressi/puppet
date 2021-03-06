#!/usr/bin/env sh

if [ -z "$1" ] ; then echo "enter host group: vagrant | dev | etc" && exit 1 ; fi
if ! command -v ansible ; then echo ansible is not installed ;  exit 0 ; fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook \
    -i "$DIR"/ansible-hosts.txt \
    "$DIR"/ansible-playbook.yaml \
    --limit "$1"
