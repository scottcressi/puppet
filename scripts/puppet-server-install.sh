#!/usr/local/env bash

# checks
if ! command -v docker-compose ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git ; then echo git is not installed ;  exit 0 ; fi
if ! command -v r10k ; then echo r10k is not installed ;  exit 0 ; fi
[[ ! "$(systemctl is-active docker)" == "active" ]] && echo Please start docker && exit 0
[[ ! -d /var/tmp/pupperware ]] && git clone https://github.com/puppetlabs/pupperware.git /var/tmp/pupperware
[[ ! -d /var/tmp/puppetboard ]] && git clone https://github.com/scottcressi/docker-compose-puppetboard.git /var/tmp/puppetboard

# start puppet
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
cd /var/tmp/pupperware && docker-compose up -d

echo as root run: r10k deploy environment -c r10k.yaml --verbose
echo do not forget to manually clone to accept the fingerprint
