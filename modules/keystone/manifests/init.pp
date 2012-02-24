class keystone(
  $package_ensure = 'present',
  $log_file = '/var/log/keystone/keystone.log',
  $log_verbose = 'False',
  $log_debug = 'False',
  $public_port = '5000',
  $admin_port = '35357',
  $admin_token = 'ADMIN',
  $compute_port = '3000',
  $use_syslog = 'False',
  $syslog_facility = 'LOG_LOCAL0',
  $sql_connection = 'sqlite:////var/lib/keystone/keystone.sqlite',
  $sql_idle_timeout = '200',
  $sql_min_pool_size = '5',
  $sql_max_pool_size = '10',
  $sql_pool_timeout = '200',
  $identity_driver = 'keystone.identity.backends.sql.Identity',
  $catalog_driver = 'keystone.catalog.backends.templated.TemplatedCatalog',
  $catalog_template_file = '/etc/keystone/default_catalog.templates',
  $token_driver = 'keystone.token.backends.kvs.Token',
  $expiration = '86400',
  $policy_driver = 'keystone.policy.backends.simple.SimpleMatch',
  $ec2_driver = 'keystone.contrib.ec2.backends.sql.Ec2'
) {

  package { 'openstack-keystone': ensure => $package_ensure }
  package { 'python-keystoneclient': ensure => $package_ensure }

  exec { "keystone-db-sync":
    command     => "/usr/bin/keystone-manage db_sync",
    user     => "keystone",
    refreshonly => true,
    require     => Package["openstack-keystone"]
  }

  file { "/etc/keystone/keystone.conf":
    ensure  => present,
    owner   => 'keystone',
    group   => 'root',
    mode    => 640,
    content => template('keystone/keystone.conf.erb'),
    require => Package['openstack-keystone'],
    notify        => Exec["keystone-db-sync"]
  }

  file { '/etc/keystone/':
    ensure  => directory,
    owner   => 'keystone',
    group   => 'root',
    mode    => 770,
    require => Package['openstack-keystone']
  }

  service { "openstack-keystone":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File["/etc/keystone/keystone.conf"],
    require => Package['openstack-keystone']
  }

  Exec['keystone-db-sync'] ~> Service['openstack-keystone']

}
