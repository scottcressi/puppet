DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "`docker images | awk '{print $1}' | grep centos/systemd-puppet`" != "centos/systemd-puppet" ] ; then
cd docker/build
docker build --tag centos/systemd-puppet .
cd $DIR
fi

if [ -z $1 ] ; then echo enter test/destroy ; fi

test(){
# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -v puppet.internal.pem | sudo xargs rm -f

LIST='kvm kvm'
for i in $LIST ; do
  NAME=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`
  # run test
  docker run --net pupperware_default --name=$NAME --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro centos/systemd-puppet
  docker exec -e FACTER_virtual=$i -ti $NAME /bin/bash -c "/opt/puppetlabs/bin/puppet agent --test --certname $NAME --no-daemonize --summarize --environment=production --server puppet"
done
}

destroy(){
for i in `docker ps | grep centos/systemd-puppet | awk '{print $1}'` ; do
docker kill $i
done
}

$@
