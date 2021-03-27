#!/usr/local/env sh

export PUPPETDB_VERSION=7.1.0
export PUPPETSERVER_VERSION=7.1.0
export PUPPERWARE_ANALYTICS_ENABLED=false
#export DNS_ALT_NAMES=foo

pupperware_dir=/var/tmp
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# check binaries
if ! command -v docker-compose > /dev/null ; then echo docker-compose is not installed ;  exit 0 ; fi
if ! command -v docker > /dev/null ; then echo docker is not installed ;  exit 0 ; fi
if ! command -v git > /dev/null ; then echo git is not installed ;  exit 0 ; fi

# check docker service
[ ! "$(systemctl is-active docker)" = "active" ] && echo Please start docker && exit 0

# check pupperware repo
[ ! -d $pupperware_dir/pupperware ] && git clone https://github.com/puppetlabs/pupperware.git $pupperware_dir/pupperware

# start puppet
docker-compose -f $pupperware_dir/pupperware/docker-compose.yml up -d
docker-compose -f "$DIR"/docker/docker-compose.yml up -d

# run r10k
docker exec -ti pupperware_puppet_1 sh -c " \
                                            if ! command -v ssh > /dev/null; then apt-get update && apt-get install -y openssh-client vim ; fi ;\
                                            mkdir -p ~/.ssh ; chmod 400 ~/.ssh ;\
                                            echo StrictHostKeyChecking no > ~/.ssh/config ;\
                                            "
docker cp ~/.ssh/id_rsa pupperware_puppet_1:/root/.ssh/id_rsa
docker cp "$DIR"/../r10k.yaml pupperware_puppet_1:/var/tmp/r10k.yaml
docker exec -ti pupperware_puppet_1 sh -c "r10k deploy environment -c /var/tmp/r10k.yaml --puppetfile --verbose --cachedir /var/tmp/r10k_cache"
docker exec -ti pupperware_puppet_1 sh -c "mkdir -p /etc/puppetlabs/code/environments/production"

# eyaml create keys
eyaml_check=$(aws secretsmanager list-secrets --region us-east-1 --query SecretList[*].Name | grep -c eyaml)
if [ "$eyaml_check" != "2" ] ; then
    echo "eyaml keys do not exist in aws secret manager"
    if [ ! -d keys ] ; then
        echo "local eyaml keys do not exist, creating"
        eyaml createkeys
        echo uploading keys to aws secret manager
        aws secretsmanager  create-secret --name eyaml-privatekey --region us-east-1
        aws secretsmanager  create-secret --name eyaml-publickey --region us-east-1
        aws secretsmanager put-secret-value --secret-id eyaml-privatekey --region us-east-1 --secret-string "$(cat keys/private_key.pkcs7.pem)"
        aws secretsmanager put-secret-value --secret-id eyaml-publickey --region us-east-1 --secret-string "$(cat keys/public_key.pkcs7.pem)"
    fi
else
    echo eyaml keys exist in aws secret manager, skipping creation
fi

# eyaml download keys
aws secretsmanager get-secret-value --secret-id eyaml-publickey --region  us-east-1 --query SecretString --output text > public_key.pkcs7.pem
aws secretsmanager get-secret-value --secret-id eyaml-privatekey --region  us-east-1 --query SecretString --output text > private_key.pkcs7.pem

# eyaml copy keys into container
docker exec -ti pupperware_puppet_1 sh -c "mkdir -p /etc/puppetlabs/puppet/keys"
docker cp private_key.pkcs7.pem pupperware_puppet_1:/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem
docker cp public_key.pkcs7.pem pupperware_puppet_1:/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem
rm -f private_key.pkcs7.pem
rm -f public_key.pkcs7.pem
