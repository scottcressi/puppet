# server install
```
bash scripts/puppet-server-install.sh
```

# change facts when testing
```
export FACTER_$foo=bar
```

# testing with vagrant (optional)
```
bash scripts/puppet-agent-test.sh --client-test-metal
puppet agent -t --environment $ENV
```

# testing with docker (optional)
```
bash scripts/puppet-agent-test.sh --client-test-docker
puppet agent -t --environment $ENV
```

# syntax checking (optional)
```
bash scripts/check.sh
```

# installing agent on servers (optional)
1. edit scripts/ansible-hosts.txt
```
vi scripts/ansible-hosts.txt
```
2. run agent install script
```
scripts/puppet-agent-install.sh $HOSTGROUP
```
