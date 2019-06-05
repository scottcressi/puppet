# r10k deploy
docker run \
-w /var/tmp \
-v ${PWD}:/var/tmp \
-v ~/.ssh/:/root/.ssh \
puppet/r10k \
deploy \
environment \
-c r10k.yaml \
--verbose
