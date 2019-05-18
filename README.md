* 1. bake puppet into centos systemd image
```
cd docker/build/
bash build.sh
```
* 2. run puppet server
```
cd docker
docker-compose up puppet
```
* 3. run puppet agent
```
bash puppet-agent-test.sh
```
