#!/usr/local/env sh

export PUPPETDB_VERSION=7.2.0
export PUPPETSERVER_VERSION=7.1.1
export PUPPERWARE_ANALYTICS_ENABLED=false
pupperware_dir=/var/tmp
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

check(){
    if ! command -v docker-compose > /dev/null ; then echo docker-compose is not installed ;  exit 0 ; fi
    if ! command -v docker > /dev/null ; then echo docker is not installed ;  exit 0 ; fi
    if ! command -v git > /dev/null ; then echo git is not installed ;  exit 0 ; fi
    [ ! "$(systemctl is-active docker)" = "active" ] && echo Please start docker && exit 0
    [ ! -d $pupperware_dir/pupperware ] && git clone https://github.com/puppetlabs/pupperware.git $pupperware_dir/pupperware
}

puppetserver_build(){
    if [ "$(docker image ls | grep -c puppetserver-custom)" = 0 ] ; then
        echo ; echo building puppetserver image ; echo
        docker build --tag puppetserver-custom --file "$DIR"/docker/master/Dockerfile .
    fi
}

puppetserver_start(){
    echo ; echo starting puppetserver ; echo
    docker-compose -f $pupperware_dir/pupperware/docker-compose.yml up -d
}

r10k_run(){
    echo ; echo running r10k ; echo
    docker exec -ti pupperware_puppet_1 sh -c " \
                                                mkdir -p ~/.ssh ; chmod 400 ~/.ssh ;\
                                                echo StrictHostKeyChecking no > ~/.ssh/config ;\
                                                "
    docker cp ~/.ssh/id_rsa pupperware_puppet_1:/root/.ssh/id_rsa
    docker cp "$DIR"/../r10k.yaml pupperware_puppet_1:/var/tmp/r10k.yaml
    docker exec -ti pupperware_puppet_1 sh -c "r10k deploy environment -c /var/tmp/r10k.yaml --puppetfile --verbose --cachedir /var/tmp/r10k_cache"
    docker exec -ti pupperware_puppet_1 sh -c "mkdir -p /etc/puppetlabs/code/environments/production"
    echo "* * * * * $(whoami) docker exec pupperware_puppet_1 sh -c 'r10k deploy environment -c /var/tmp/r10k.yaml --puppetfile --verbose --cachedir /var/tmp/r10k_cache'" | sudo tee /etc/cron.d/r10k > /dev/null

}

eyaml_keys_create(){
    eyaml_check=$(aws secretsmanager list-secrets --region us-east-1 --query SecretList[*].Name | grep -c eyaml)
    if [ "$eyaml_check" != "2" ] ; then
        echo ; echo "eyaml keys do not exist in aws secret manager", please create eyaml-privatekey and eyaml-publickey and run again
        exit 0
    fi
}

eyaml_keys_download(){
    echo ; echo eyaml download ; echo
    aws secretsmanager get-secret-value --secret-id eyaml-publickey --region  us-east-1 --query SecretString --output text > public_key.pkcs7.pem
    aws secretsmanager get-secret-value --secret-id eyaml-privatekey --region  us-east-1 --query SecretString --output text > private_key.pkcs7.pem
}

eyaml_keys_copy(){
    echo ; echo eyaml copy ; echo
    docker exec -ti pupperware_puppet_1 sh -c "mkdir -p /etc/puppetlabs/puppet/keys"
    docker cp private_key.pkcs7.pem pupperware_puppet_1:/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem
    docker cp public_key.pkcs7.pem pupperware_puppet_1:/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem
    rm -f private_key.pkcs7.pem
    rm -f public_key.pkcs7.pem
}

misc_start(){
    echo ; echo misc start ; echo
    docker-compose -f "$DIR"/docker/docker-compose.yml up -d
}

check_puppetserver_health(){
    echo
    while ! nc -z localhost 8140; do
        echo Waiting for puppetserver to launch on 8140...
        sleep 1
    done
    echo "puppetserver launched"
}

check_puppetserver_ca_health(){
    echo
    while [ "$(docker exec -ti pupperware_puppet_1 puppetserver ca list --all > /dev/null ; echo $?)" -ne 0 ] ; do
        echo Waiting for puppetserver ca to launch...
        sleep 5
    done
    echo "puppetserver ca launched"
}

check
puppetserver_build
puppetserver_start
check_puppetserver_health
check_puppetserver_ca_health
misc_start
r10k_run
#eyaml_keys_create
#eyaml_keys_download
#eyaml_keys_copy
