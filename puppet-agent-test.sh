# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -i `hostname` | xargs sudo rm -f

NAME=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`

# run test
docker run \
--net host \
--name=$NAME \
--privileged \
-d \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/run/docker.sock \
diamanti/c7-systemd-dbus:latest

docker exec -ti $NAME /bin/bash -c "yum install -y https://yum.puppet.com/puppet6/puppet-release-el-7.noarch.rpm"
docker exec -ti $NAME /bin/bash -c "yum install -y puppet-agent-6.4.2"
docker exec -e FACTER_virtual=kvm -ti $NAME /bin/bash -c "/opt/puppetlabs/bin/puppet agent --verbose --no-daemonize --summarize --environment=production --server puppet"
