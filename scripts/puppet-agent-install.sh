#!/usr/bin/env bash

PUPPET_FACTSDIR=/opt/puppetlabs/facter/facts.d
PUPPET_BINDIR=/opt/puppetlabs/bin
PUPPET_CONFDIR=/etc/puppetlabs/puppet

PUPPET_ROLE=$1
PUPPET_ENVIRONMENT=$2
PUPPET_SERVER=$3
CONFIRM=$4

if [ -z "$PUPPET_ROLE" ] ; then echo missing puppet role && exit 1 ; fi
if [ -z "$PUPPET_ENVIRONMENT" ] ; then echo missing puppet env && exit 1 ; fi
if [ -z "$PUPPET_SERVER" ] ; then echo missing puppet server && exit 1 ; fi

echo
echo "role:   $PUPPET_ROLE"
echo "env:    $PUPPET_ENVIRONMENT"
echo "server: $PUPPET_SERVER"
echo

if [ "$CONFIRM" != "confirm" ] ; then
    echo set confirm to apply
    exit 0
fi

if [ "$(awk /^ID/ /etc/os-release)" == "ID=debian" ] ; then
    echo put debian packages here
elif [ "$(awk /^ID/ /etc/os-release)" == "ID=centos" ] ; then
    yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm
    yum install -y puppet-agent-6.18.0
fi

echo "
puppetserver=$PUPPET_SERVER
environment=$PUPPET_ENVIRONMENT
role=$PUPPET_ROLE
" > $PUPPET_FACTSDIR/facts.txt

echo "
[agent]
server      = $PUPPET_SERVER
environment = $PUPPET_ENVIRONMENT
certname    = $PUPPET_ROLE-$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 ; echo '')
runinterval = 30m
" > $PUPPET_CONFDIR/puppet.conf

$PUPPET_BINDIR/puppet agent -t
