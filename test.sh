find ssl/ -type f | grep -i `hostname` | xargs sudo rm -f
docker run -e FACTER_virtual=kvm --net host puppet/puppet-agent agent --server puppet --verbose --no-daemonize --summarize --noop \
--environment=production
