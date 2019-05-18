set -x

# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -v puppet.internal.pem | sudo xargs rm -f

LIST='kvm docker'
for i in $LIST ; do

NAME=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`

# run test
docker run \
--net host \
--name=$NAME \
--privileged \
-d \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
centos/systemd


docker exec -ti $NAME /bin/bash -c "yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm"
docker exec -ti $NAME /bin/bash -c "yum install -y puppet-agent-6.4.2"
docker exec -ti $NAME /bin/bash -c "echo '
SELINUX=enforcing
SELINUXTYPE=targeted
' > /etc/selinux/config
"
docker exec -e FACTER_virtual=$i -ti $NAME /bin/bash -c "/opt/puppetlabs/bin/puppet agent --test --certname $NAME --verbose --no-daemonize --summarize --environment=production --server puppet"

done
