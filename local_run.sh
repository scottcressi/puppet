if [ "$#" -ne 1 ]
then
  echo
  echo Ex. bash local_run.sh SOMEROLE
  echo
  echo "Missing one of the following:"
  echo
  ls -la ../hieradata/role/ | awk '{print $9}' | sed 's/.yaml//g' | tail -n +4
  exit 1
fi

FACTER_role=$1 puppet apply --noop manifests/site.pp --modulepath modules:modules_forge --hiera_config hiera.yaml
