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
    cd "$DIR"/docker/client && docker build --tag puppet-test-client .
    docker run \
        -ti \
        --net pupperware_default \
        --name="$NAME" \
        puppet-test-client
}

client-test-metal(){
    vagrant up --provision --provider="$PROVIDER"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --client-test-docker)
        client-test-docker
      ;;
    --client-test-metal)
        echo NOTE: when using libvirt provider you must add the user that is running vagrant to the libvirt group
        echo NOTE: to remove a previous conflicting virtualbox network run: VBoxManage hostonlyif remove vboxnetX
        echo NOTE: to remove duplicate domain run: sudo virsh undefine "$DOMAIN"
        echo NOTE: you must have the following entry in your host systems /etc/hosts: \$YOUR_HOST_IP puppet
        echo
        if [ "$(vagrant plugin list | grep -c vagrant-dns)" = 0 ] ; then echo please run: vagrant plugin install vagrant-dns ; fi
        if [ "$(vagrant plugin list | grep -c vagrant-libvirt)" = 0 ] ; then echo please run: vagrant plugin install vagrant-libvirt ; fi
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
