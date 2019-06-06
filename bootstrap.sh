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
  exit 0
fi

if [ `sudo systemctl is-active docker` == "active" ]; then
  echo Docker is Running
else
  echo Please start docker
fi

if command -v git ; then
  echo git is installed
else
  echo Please install git
  exit 0
fi

if [ ! -d "../hieradata" ] ; then
  echo please clone hieradata next to puppet repo
  exit 0
fi

if [ ! -d "../pupperware" ] ; then
  echo please clone pupperware next to puppet repo
  exit 0
fi

if [ ! -f "`eval echo ~/.ssh/id_rsa`" ] ; then
  echo please install puppet ssh key
  exit 0
fi

cd $DIR
bash r10k.sh

cd $DIR/../pupperware
export DNS_ALT_NAMES=foo
export PUPPERWARE_ANALYTICS_ENABLED=false
docker-compose up -d

cd $DIR/docker
docker-compose up -d
