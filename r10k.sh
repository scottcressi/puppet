#!/usr/bin/env bash

sudo r10k deploy environment -c r10k.yaml --puppetfile --verbose --cachedir /var/tmp/r10k_cache
