# clean ssl
find docker/volumes/puppet/ssl/ca/signed -type f | grep -i `hostname` | xargs sudo rm -f

# run test
docker run \
-e FACTER_virtual=kvm \
--net host \
puppet/puppet-agent:6.4.2 \
agent \
--server puppet \
--verbose \
--no-daemonize \
--summarize \
--noop \
--environment=production
