#!/usr/local/env bash

if [ -z "$1" ] ; then
  echo hieradata repo url required
  exit 0
fi

HIERADATA=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! command -v docker-compose ; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

if ! command -v docker ; then
  echo Docker is not installed
  exit 0
fi

if [ ! "$(sudo systemctl is-active docker)" == "active" ]; then
  echo Please start docker
  exit 0
fi

if ! command -v git ; then
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

cd "$DIR"
bash r10k.sh

cd "$DIR"/../pupperware
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
docker-compose up -d

cd "$DIR"
sudo cp hiera.yaml ../pupperware/volumes/puppet/hiera.yaml

cd "$DIR"/docker
docker-compose up -d

if [ ! -d "$DIR"/../pupperware/volumes/puppet/hieradata ] ; then
  sudo chmod 777 "$DIR"/../pupperware/volumes/puppet
  git clone "$HIERADATA" "$DIR"/../pupperware/volumes/puppet/hieradata
fi
