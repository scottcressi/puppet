if ! command -v ansible ; then echo ansible is not installed ;  exit 0 ; fi

ansible-playbook -i ./puppet-agent-install-ansible-hosts.txt ./puppet-agent-install-ansible-playbook.yaml
