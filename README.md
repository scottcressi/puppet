# server install
1. run bootstrap
```
bash scripts/puppet-server-install.sh
```
2. run r10k
```
bash r10k.sh
```

# testing
1. edit scripts/facts.txt (optional)
```
vi scripts/facts.txt
```
2. run puppet agent
```
bash scripts/puppet-agent-test.sh test
```
