#!/usr/bin/env bash

PUPPET_ROLE=$1
PUPPET_ENVIRONMENT=$2
PUPPET_SERVER=$3

if [ -z "$PUPPET_ROLE" ] ; then echo missing puppet role && exit 1 ; fi
if [ -z "$PUPPET_ENVIRONMENT" ] ; then echo missing puppet env && exit 1 ; fi
if [ -z "$PUPPET_SERVER" ] ; then echo missing puppet server && exit 1 ; fi

yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm
yum install -y puppet-agent-6.18.0

echo "
puppetserver=$PUPPET_SERVER
environment=$PUPPET_ENVIRONMENT
role=$PUPPET_ROLE
" > /opt/puppetlabs/facter/facts.d/facts.txt

echo "
[agent]
server      = $PUPPET_SERVER
environment = $PUPPET_ENVIRONMENT
certname    = $PUPPET_ROLE-$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')
runinterval = 30m
" > /etc/puppetlabs/puppet/puppet.conf

/opt/puppetlabs/bin/puppet agent -t
