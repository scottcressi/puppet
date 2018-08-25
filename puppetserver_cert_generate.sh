# get script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$#" -ne 1 ]
then
  echo "Requires certname"
  exit 1
fi

echo check if puppet is installed
if [ `gem list  --installed puppet` == true ] ; then
echo puppet installed already
else
sudo gem install puppet
fi

PUPPET_CERT_NAME=$1

echo cert clean
find ~/.puppetlabs/etc/puppet/ssl/ -type f | xargs rm -f
rm -rf /tmp/$PUPPET_CERT_NAME

echo cert path generation
mkdir -p ~/.puppetlabs/etc/puppet/ssl/ca/requests

echo cert generate
puppet certificate generate puppet --ca-location local --dns-alt-names $PUPPET_CERT_NAME

echo
echo
echo cert sign
puppet cert sign --allow-dns-alt-names --all
echo
echo

echo copy signined cert into certs
cp -rp ~/.puppetlabs/etc/puppet/ssl/ca/signed/puppet.pem ~/.puppetlabs/etc/puppet/ssl/certs/

echo cert isolate
cp -rp ~/.puppetlabs/etc/puppet/ssl /$DIR/$PUPPET_CERT_NAME

echo
echo
echo cert verification
puppet cert print --all | grep DNS
echo
echo

echo "###"
echo "### PLEASE COMMIT CERT ###"
echo "###"
