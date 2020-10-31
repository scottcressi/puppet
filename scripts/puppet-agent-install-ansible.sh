if ! command -v ansible ; then echo ansible is not installed ;  exit 0 ; fi

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook \
    --become \
    --user osboxes \
    --become-method sudo \
    --become-user root \
    -i ./puppet-agent-install-ansible-hosts.txt \
    ./puppet-agent-install-ansible-playbook.yaml
