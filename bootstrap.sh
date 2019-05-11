# this script assumes the following:
# git is installed
# docker is installed
# ssh key exists in root
# puppet repo lives side by side hiera repo, but can live anywhere on the os

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if command -v docker-compose ; then
  echo docker-compose is installed
else
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

if command -v docker ; then
  echo Docker is installed
else
  echo Please install Docker
fi

if [ `sudo systemctl is-active docker` == "active" ]; then
  echo Docker is Running
else
  sudo systemctl start docker
fi

cd $DIR/../hieradata
git pull

cd $DIR
bash r10k.sh

cd $DIR/docker
DNS_ALT_NAMES=foo docker-compose up -d
