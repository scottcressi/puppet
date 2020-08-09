if [ -z "$1" ] ; then echo missing puppet role && exit 1 ; fi
if [ -z "$2" ] ; then echo missing puppet env && exit 1 ; fi
if [ -z "$3" ] ; then echo missing team && exit 1 ; fi
if [ -z "$4" ] ; then echo missing puppet server && exit 1 ; fi

PUPPET_ROLE=$1
PUPPET_ENVIRONMENT=$2
PUPPET_TEAM=$3
PUPPET_HOST=$4

# pre set
INSTANCE_ID=$ROLE-`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`

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
runinterval = 1d
" > /etc/puppetlabs/puppet/puppet.conf

/opt/puppetlabs/bin/puppet agent -t
