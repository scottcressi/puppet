# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -i `hostname` | xargs sudo rm -f

# run test
docker run \
-e FACTER_virtual=kvm \
--net host \
centos/systemd \
/bin/bash \
-c "yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm && yum install -y puppet-agent-6.4.2 && /opt/puppetlabs/bin/puppet agent --verbose --no-daemonize --summarize --environment=production --server puppet"
