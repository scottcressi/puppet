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
bash scripts/check.sh
```

# installing agent on server (optional)
1. run agent install script
```
bash <(curl -s https://raw.githubusercontent.com/scottcressi/puppet/master/scripts/puppet-agent-install.sh) somerole someenv someserver
```
2. run agent install script with confirm to apply
```
bash <(curl -s https://raw.githubusercontent.com/scottcressi/puppet/master/scripts/puppet-agent-install.sh) somerole someenv someserver confirm
```

# TODO:
```
implement vault for secrets
```
