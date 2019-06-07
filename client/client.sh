PUPPET_ROLE=$1
PUPPET_ENVIRONMENT=$2
PUPPET_TEAM=$3
INSTANCE_ID=`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`
echo $CERT

prerequisites() {
 yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm
 yum install -y puppet-agent-6.4.2
}

facts () {
  puppet_role=$1
  puppet_env=$2
  puppet_host=$3
  puppet_team=$4
  vpcid=$5

  echo "
puppetserver=$puppet_host
environment=$puppet_env
role=$puppet_role
team=$puppet_team
vpcid=$vpcid
  " > /opt/puppetlabs/facter/facts.d/facts.txt
}

puppetConf () {
  puppet_env=$1
  puppet_host=$2
  echo "
[agent]
server = $puppet_host
environment = $puppet_env
certname    = $INSTANCE_ID
" > /etc/puppetlabs/puppet/puppet.conf
}

prerequisites
if [ "`/opt/puppetlabs/bin/facter dmi.product.name`" == "HVM domU" ] ; then
    MAC=`/opt/puppetlabs/bin/facter ec2_metadata.mac`
    VPC=`/opt/puppetlabs/bin/facter ec2_metadata.network.interfaces.macs.$MAC.vpc-id`
    PUPPET_HOST="puppet-$VPC.example.com"
else
    PUPPET_HOST=puppet-$PUPPET_ENVIRONMENT.example.com
fi
facts $PUPPET_ROLE $PUPPET_ENVIRONMENT $PUPPET_HOST $PUPPET_TEAM $VPC
puppetConf $PUPPET_ENVIRONMENT $PUPPET_HOST

/opt/puppetlabs/bin/puppet agent -t --noop
