REPO=$1

[ -z "$REPO" ] && echo "please set path to puppet repo" && exit 1;

if [ -x "$(command -v docker)" ]; then
  echo "Docker is installed"
else
  echo "Please install Docker"
fi

if [ `sudo systemctl is-active docker` == "active" ]; then
  echo "Docker is Running"
else
  echo "Please start Docker"
fi

docker run -w /var/tmp -v $REPO:/var/tmp puppet/r10k puppetfile check
docker run -w /var/tmp -v $REPO:/var/tmp puppet/r10k puppetfile install --color --verbose info --force
docker run -v $REPO:/var/tmp puppet/puppet-agent module list --modulepath /var/tmp/modules_forge --tree
