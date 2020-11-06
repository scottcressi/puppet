# server install
1. run bootstrap
```
bash scripts/puppet-server-install.sh
```

# testing (optional)
1. edit scripts/facts.txt
```
vi scripts/facts.txt
```
2. run puppet agent test script
```
bash scripts/puppet-agent-test.sh --client-test
```
3. run puppet agent
```
puppet agent -t --environment $ENV
```

# syntax checking (optional)
1. run check script
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

# TODO:
```
implement vault for secrets
```
