if [ -z "$1" ] ; then echo enter test/destroy ; fi

test(){
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    cd "$DIR"/docker/build || exit
    docker build --tag centos/systemd-puppet .
    cd "$DIR" || exit

    NAME="test-puppet-agent-$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)"
    docker run --net pupperware_default --name="$NAME" -d -v ~/repos/personal/puppet/scripts/facts.txt:/opt/puppetlabs/facter/facts.d/facts.txt centos/systemd-puppet
    docker exec -ti "$NAME" /bin/bash
}

destroy(){
    set -x
    for i in $(docker ps | grep centos/systemd-puppet | awk '{print $1}') ; do
    docker kill $i
    done
}

"$@"
