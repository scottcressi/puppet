#!/usr/local/env bash

[[ -z "$1" ]] && { echo "specify puppet repo url" ; exit 1; }

REPO=$1

# checks
if ! command -v docker-compose ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git ; then echo git is not installed ;  exit 0 ; fi
[[ ! "$(systemctl is-active docker)" == "active" ]] && echo Please start docker && exit 0
[[ "$(git ls-remote > /dev/null 2>&1 ; echo $?)" -ne "0" ]] && echo git does not have permission to clone && exit 0
[[ ! -d /var/tmp/pupperware ]] && git clone https://github.com/puppetlabs/pupperware.git /var/tmp/pupperware
[[ ! -d /var/tmp/puppet ]] && git clone "$REPO" /var/tmp/puppet
[[ ! -d /var/tmp/puppetboard ]] && git clone https://github.com/scottcressi/docker-compose-puppetboard.git /var/tmp/puppetboard

# start puppet
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
cd /var/tmp/pupperware && docker-compose up -d

echo as root run: r10k deploy environment -c r10k.yaml --verbose
