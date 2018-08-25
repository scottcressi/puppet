hiera_include('classes')

if $facts[kernel] == 'Linux' {

$minute = seeded_rand(15, "$::ipaddress")
$minute1 = seeded_rand(15, "$::ipaddress") + 15
$minute2 = seeded_rand(15, "$::ipaddress") + 30

file { '/etc/cron.d/puppet_agent':
  ensure  => 'present',
  content => "$minute,$minute1,$minute2 * * * * root /opt/puppetlabs/puppet/bin/puppet agent --onetime --no-report\n",
  mode    => '0644',
  owner   => 'root',
  group   => 'root',
}
}
