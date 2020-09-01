#!/usr/bin/env bash

if [ -z "$1" ] ; then echo missing puppet role && exit 1 ; fi
if [ -z "$2" ] ; then echo missing puppet env && exit 1 ; fi
if [ -z "$3" ] ; then echo missing team && exit 1 ; fi
if [ -z "$4" ] ; then echo missing puppet server && exit 1 ; fi

PUPPET_ROLE=$1
PUPPET_ENVIRONMENT=$2
PUPPET_TEAM=$3
PUPPET_HOST=$4

# pre set
UUID="$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')"
INSTANCE_ID=$ROLE-$UUID

yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm
yum install -y puppet-agent-6.17.0

echo "
puppetserver=$PUPPET_HOST
environment=$PUPPET_ENVIRONMENT
role=$PUPPET_ROLE
team=$PUPPET_TEAM
" > /opt/puppetlabs/facter/facts.d/facts.txt

echo "
[agent]
server      = $PUPPET_HOST
environment = $PUPPET_ENVIRONMENT
certname    = $INSTANCE_ID
runinterval = 30m
" > /etc/puppetlabs/puppet/puppet.conf

/opt/puppetlabs/bin/puppet agent -t
