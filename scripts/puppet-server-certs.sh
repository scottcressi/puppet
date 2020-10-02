#!/usr/bin/env bash

if [ -z "$1" ] ; then echo enter list/clean ; fi

list(){
    docker exec -ti pupperware_puppet_1 puppetserver ca list --all
}

clean(){
    docker exec -ti pupperware_puppet_1 puppetserver ca clean --certname $1
}

"$@"
