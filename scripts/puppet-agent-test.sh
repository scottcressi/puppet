#!/usr/bin/env sh

if ! command -v docker > /dev/null ; then echo docker is not installed ;  exit 0 ; fi

if [ $# -eq 0 ] ; then
    echo """
options:
--client-test-docker
--client-test-metal
--client-destroy
--cert-list
--cert-clean \$SOMECERT
"""
    exit 0
fi

client-test-docker(){
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    UUID="$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')"
    NAME=test-puppet-agent-$UUID
    cd "$DIR"/docker/build && docker build --tag puppet-test-client .
    docker run \
        -ti \
        --net pupperware_default \
        --name="$NAME" \
        -v "$DIR"/facts.txt:/opt/puppetlabs/facter/facts.d/facts.txt \
        puppet-test-client
}

client-test-metal(){
    IP=$(ip route get 8.8.8.8 | head -1 | awk '{print $7}')
    vagrant up --provision --provider="$PROVIDER"
    vagrant ssh -c "echo $IP puppet | sudo tee -a /etc/hosts"
    vagrant ssh -c "sudo /opt/puppetlabs/bin/puppet agent -t"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --client-test-docker)
        client-test-docker
      ;;
    --client-test-metal)
        echo NOTE: when using libvirt provider you must add the user that is running vagrant to the libvirt group
        echo NOTE: to remove a previous conflicting virtualbox network run: VBoxManage hostonlyif remove vboxnetX
        echo NOTE: to install libvirt provider run: vagrant plugin install vagrant-libvirt
        echo NOTE: to remove duplicate domain run: sudo virsh undefine $DOMAIN
        echo
        [ -z "$2" ] && echo virtualbox / libvirt required && exit 0
        PROVIDER=$2
        client-test-metal
      ;;
    --client-destroy)
        docker ps | awk '/test-puppet-agent/ {print $1}' | xargs docker kill
        exit 0
      ;;
    --cert-list)
        docker exec -ti pupperware_puppet_1 puppetserver ca list --all
        exit 0
      ;;
    --cert-clean)
        docker exec -ti pupperware_puppet_1 puppetserver ca clean --certname "$2"
        exit 0
      ;;
    *)
      echo Invalid argument
      exit 1
      ;;
  esac
  shift
done
