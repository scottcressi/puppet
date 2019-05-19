1. bake puppet into centos systemd image
```
cd docker/build/
bash build.sh
```
2. run puppet server
```
cd docker
docker-compose up puppet
```
3. run puppet agent
```
bash puppet-agent-test.sh
```
4. check puppetfile validity
```
bash check-puppetfile.sh
```
5. deploy r10k to puppet server
```
bash r10k.sh
```
