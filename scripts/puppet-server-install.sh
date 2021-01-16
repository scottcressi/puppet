#!/usr/local/env sh

pupperware_dir=/var/tmp
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# checks
if ! command -v docker-compose ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git ; then echo git is not installed ;  exit 0 ; fi
[ ! "$(systemctl is-active docker)" = "active" ] && echo Please start docker && exit 0
[ ! -d $pupperware_dir/pupperware ] && git clone https://github.com/puppetlabs/pupperware.git $pupperware_dir/pupperware

# exports
#export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
export PUPPETDB_VERSION=6.12.0
export PUPPETSERVER_VERSION=6.14.0

# start puppet
docker-compose -f $pupperware_dir/pupperware/docker-compose.yml up -d
docker-compose -f "$DIR"/docker/docker-compose.yml up -d

# run r10k
docker exec -ti pupperware_puppet_1 sh -c " \
                                            if ! command -v ssh > /dev/null; then apt-get update && apt-get install -y openssh-client ; fi ;\
                                            mkdir -p ~/.ssh ; chmod 400 ~/.ssh ;\
                                            echo StrictHostKeyChecking no > ~/.ssh/config ;\
                                            "
docker cp ~/.ssh/id_rsa pupperware_puppet_1:/root/.ssh/id_rsa
docker cp "$DIR"/../r10k.yaml pupperware_puppet_1:/var/tmp/r10k.yaml
docker exec -ti pupperware_puppet_1 sh -c "r10k deploy environment -c /var/tmp/r10k.yaml --puppetfile --verbose --cachedir /var/tmp/r10k_cache"
