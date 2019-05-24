if [ "`docker images | awk '{print $1}' | grep centos/systemd-puppet`" != "centos/systemd-puppet" ] ; then
echo please build puppet image
exit 1
fi

# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -v puppet.internal.pem | sudo xargs rm -f

LIST='kvm docker'
for i in $LIST ; do

NAME=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`

# run test
docker run --net host --name=$NAME --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro centos/systemd-puppet
docker exec -e FACTER_virtual=$i -ti $NAME /bin/bash -c "/opt/puppetlabs/bin/puppet agent --test --certname $NAME --verbose --no-daemonize --summarize --environment=production --server puppet"

done
