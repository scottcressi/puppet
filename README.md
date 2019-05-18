# bake puppet into centos systemd image
- cd docker/build/
- bash build.sh

# run puppet server
- cd docker
- docker-compose up puppet

# run puppet agent
- bash puppet-agent-test.sh
