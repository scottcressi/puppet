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
2. run puppet agent container
```
bash scripts/puppet-agent-test.sh test
```
3. run puppet agent
```
puppet agent -t --environment $ENV
```

# syntax checking (optional)
1. run check script
```
bash check.sh
```
