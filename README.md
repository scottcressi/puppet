1. run puppet server / puppetdb / puppetboard
```
bash bootstrap.sh
```
2. bake puppet into centos systemd image for client testing
```
cd docker/build/
bash build.sh
```
3. check puppetfile validity
```
bash check-puppetfile.sh
```
4. deploy r10k to puppet server
```
bash r10k.sh
```
5. run puppet agent
```
bash puppet-agent-test.sh
```
