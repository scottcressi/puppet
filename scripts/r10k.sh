# r10k deploy
docker run \
-w /var/tmp \
-v ${PWD}/../:/var/tmp \
-v ~/.ssh/:/root/.ssh \
puppet/r10k \
deploy \
environment \
-c puppet/r10k.yaml \
--verbose
