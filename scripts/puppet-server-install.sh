#!/usr/local/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# checks
if ! command -v docker-compose ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git ; then echo git is not installed ;  exit 0 ; fi
if ! command -v r10k ; then echo r10k is not installed ;  exit 0 ; fi
[[ ! "$(systemctl is-active docker)" == "active" ]] && echo Please start docker && exit 0
[[ ! -d /var/tmp/pupperware ]] && git clone https://github.com/puppetlabs/pupperware.git /var/tmp/pupperware

# start puppet
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
export PUPPETDB_VERSION=6.11.0
export PUPPETSERVER_VERSION=6.12.1
cd /var/tmp/pupperware && docker-compose up -d
cd "$DIR"/docker && docker-compose up -d

echo
echo run: bash r10k.sh
echo
