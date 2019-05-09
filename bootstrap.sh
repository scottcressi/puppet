PUPPETDB_PASSWORD=$1
PUPPET_ENVIRONMENT=$2
r10k_version=2.6.5

if [ -z "$PUPPETDB_PASSWORD"  ] ; then
  echo PUPPETDB_PASSWORD and PUPPET_ENVIRONMENT required
  echo "USAGE: bash bootstrap.sh PUPPETDB_PASSWORD PUPPET_ENVIRONMENT"
  exit 1
fi
if [  -z "$PUPPET_ENVIRONMENT" ] ; then
  echo PUPPETDB_PASSWORD and PUPPET_ENVIRONMENT required
  echo "USAGE: bash bootstrap.sh PUPPETDB_PASSWORD PUPPET_ENVIRONMENT"
  exit 1
fi

export PUPPETDB_PASSWORD=$PUPPETDB_PASSWORD
export PUPPET_ENVIRONMENT=$PUPPET_ENVIRONMENT
export USER=`whoami`

prerequisites () {
  yum install -y https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
  yum install -y puppet-agent-5.5.8
  yum install -y epel-release
  yum install -y git
  yum install -y rubygems
  gem install puppet_forge -v 2.2.3
  gem install r10k -v 2.5.5
}

facts () {
  puppet_env=$1
  mkdir -p /etc/facter/facts.d
  echo "
puppetserver=puppet
environment=$puppet_env
role=puppetserver
stack=$puppet_env
  " > /etc/facter/facts.d/facts.txt
  
}

git_clone () {
  repo=$1
  git clone  git@github.example.com:DevOps/$repo.git  /etc/$repo/$repo
}

r10k_run () {
  sudo chown -R `whoami`:`whoami` /etc/puppet
  sudo chown -R `whoami`:`whoami` /etc/hieradata
  cd /etc/puppet/puppet; /usr/local/bin/r10k puppetfile install --verbose
}
docker_compose () {
  /usr/local/bin/docker-compose -f docker/docker-compose.yml -f docker/docker-compose.override.yml $1;
}

iptables -F
prerequisites
facts $PUPPET_ENVIRONMENT
git_clone hieradata
git_clone puppet
r10k_run
/opt/puppetlabs/puppet/bin/puppet apply /etc/puppet/puppet/manifests/site.pp --hiera_config /etc/puppet/puppet/hiera.yaml --modulepath /etc/puppet/puppet/modules_forge
#either kernel upgrade or this
yum downgrade -y containerd.io-1.2.2-3.el7
docker_compose "up -d"
docker_compose down
docker_compose "up -d"
