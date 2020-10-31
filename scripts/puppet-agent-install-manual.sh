#!/usr/bin/env bash

VERSION=6.19.1
REPO=https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm
PUPPET_FACTSDIR=/opt/puppetlabs/facter/facts.d
PUPPET_BINDIR=/opt/puppetlabs/bin
PUPPET_CONFDIR=/etc/puppetlabs/puppet

if [[ $# -eq 0 ]] ; then
    echo """
options:
--role \$ROLE
--env \$ENV
--server \$SERVER
--confirm
"""
    exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --role)
        PUPPET_ROLE=$2
      ;;
    --env)
        PUPPET_ENVIRONMENT=$2
      ;;
    --server)
        PUPPET_SERVER=$2
      ;;
    --confirm)
        CONFIRM=true
      ;;
  esac
  shift
done

if [ -z "$PUPPET_ROLE" ] ; then echo missing puppet role && exit 1 ; fi
if [ -z "$PUPPET_ENVIRONMENT" ] ; then echo missing puppet env && exit 1 ; fi
if [ -z "$PUPPET_SERVER" ] ; then echo missing puppet server && exit 1 ; fi

echo
echo "role:   $PUPPET_ROLE"
echo "env:    $PUPPET_ENVIRONMENT"
echo "server: $PUPPET_SERVER"
echo

if [ "$CONFIRM" != "true" ] ; then
    echo set confirm to apply
    exit 0
fi

OS=$(awk /^ID=/ /etc/os-release | sed s/\"//g)
if [ "$OS" == "ID=centos" ] ; then
    yum install -y $REPO
    yum install -y puppet-agent-$VERSION
elif [ "$OS" == "ID=debian" ] ; then
    echo put debian packages here
    exit 0
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
