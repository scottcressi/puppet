#!/usr/bin/env sh

if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi

if [ $# -eq 0 ] ; then
    echo """
options:
--client-test
--client-destroy
--cert-list
--cert-clean \$SOMECERT
"""
    exit 0
fi

client-test(){
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    UUID="$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')"
    NAME=test-puppet-agent-$UUID
    cd "$DIR"/docker/build && docker build --tag centos/systemd-puppet .
    docker run \
        -d \
        --privileged \
        --net pupperware_default \
        --name="$NAME" \
        -v "$DIR"/facts.txt:/opt/puppetlabs/facter/facts.d/facts.txt \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro centos/systemd-puppet
    docker exec -ti "$NAME" /bin/bash
}

while [ $# -gt 0 ]; do
  case "$1" in
    --client-test)
        client-test
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
