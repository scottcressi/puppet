#!/usr/local/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -x which ] ; then
  echo which is not installed
  exit 0
fi

if [ -x docker-compose ] ; then
  curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

if [ -x docker-ce ] ; then
  echo Docker is not installed
  exit 0
fi

if [ ! "$(systemctl is-active docker)" == "active" ]; then
  echo Please start docker
  exit 0
fi

if [ -x git ] ; then
  echo git is not installed
  exit 0
fi

if [ ! -f "$(eval echo ~/.ssh/id_rsa)" ] ; then
  echo please install puppet ssh key
  exit 0
fi

if [ ! -d "$DIR"/../pupperware ] ; then
  git clone https://github.com/puppetlabs/pupperware.git "$DIR"/../pupperware
fi

if [ -z "$1" ] ; then
  echo hieradata repo url required
  exit 0
fi

HIERADATA=$1

cd "$DIR"/../pupperware || exit
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
docker-compose up -d

cd "$DIR"/docker || exit
docker-compose up -d

cd "$DIR" || exit
bash r10k.sh

cd "$DIR" || exit
if [ ! -f "$(eval echo ../pupperware/volumes/puppet/hiera.yaml)" ] ; then
  echo no hiera.yaml found
  exit 0
fi

if [ ! -d "$DIR"/../pupperware/volumes/puppet/hieradata ] ; then
  chmod 777 "$DIR"/../pupperware/volumes/puppet
  git clone "$HIERADATA" "$DIR"/../pupperware/volumes/puppet/hieradata
fi
