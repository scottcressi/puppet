DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

docker run -w /var/tmp -v $DIR:/var/tmp puppet/r10k puppetfile check
docker run -w /var/tmp -v $DIR:/var/tmp puppet/r10k puppetfile install --color --verbose notice --force
docker run -v $DIR:/var/tmp puppet/puppet-agent module list --modulepath /var/tmp/modules_forge --tree
