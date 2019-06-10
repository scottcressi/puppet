0. clone pupperware next to puppet repo
```
git clone git@github.com:puppetlabs/pupperware.git ../pupperware
```
1. run puppet server / puppetdb / puppetboard
```
bash bootstrap.sh
```
3. clone hieradata into pupperware/volumes/puppet/
4. check puppetfile validity
```
bash check-puppetfile.sh
```
5. deploy r10k to puppet server
```
bash r10k.sh
```
6. run puppet agent
```
bash puppet-agent-test.sh
```
