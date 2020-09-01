#!/usr/bin/env bash

if [ -z "$1" ] ; then echo enter test/destroy ; fi

test(){
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    cd "$DIR"/docker/build || exit
    docker build --tag centos/systemd-puppet .
    cd "$DIR" || exit

    UUID="$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')"
    NAME=test-puppet-agent-$UUID
    docker run --net pupperware_default --name="$NAME" -d -v "$DIR"/facts.txt:/opt/puppetlabs/facter/facts.d/facts.txt --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro centos/systemd-puppet
    docker exec -ti "$NAME" /bin/bash
}

destroy(){
    docker ps | grep test-puppet-agent | awk '{print $1}' |xargs docker kill
}

"$@"
