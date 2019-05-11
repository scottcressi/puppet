# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -i `hostname` | xargs sudo rm -f

# run test
docker run \
-e FACTER_virtual=kvm \
--net host \
--name=c7 \
--privileged \
-d \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/run/docker.sock \
diamanti/c7-systemd-dbus:latest

docker exec -ti c7 /bin/bash -c "yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm"
docker exec -ti c7 /bin/bash -c "yum install -y puppet-agent-6.4.2"
docker exec -ti c7 /bin/bash -c "/opt/puppetlabs/bin/puppet agent --verbose --no-daemonize --summarize --environment=production --server puppet"
