#!/usr/local/env bash

[[ -z "$1" ]] && { echo "specify puppet repo url" ; exit 1; }

REPO=$1

if ! command -v kind ; then echo which is not installed ;  exit 0 ; fi
if ! command -v docker-compose ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git ; then echo git is not installed ;  exit 0 ; fi

[[ ! "$(systemctl is-active docker)" == "active" ]] && echo Please start docker && exit 0

[[ ! -d /var/tmp/pupperware ]] && git clone https://github.com/puppetlabs/pupperware.git /var/tmp/pupperware
[[ ! -d /var/tmp/puppet ]] && git clone "$REPO" /var/tmp/puppet

export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
cd /var/tmp/pupperware && docker-compose up -d
