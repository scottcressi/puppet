# r10k deploy
docker run \
-w /var/tmp \
-v ~/repos/personal/puppet/:/var/tmp \
-v ~/.ssh/:/root/.ssh \
puppet/r10k \
deploy \
environment \
`git rev-parse --abbrev-ref HEAD` \
-c r10k.yaml \
--verbose
