class glance(
  $package_ensure = 'present',
  $keystone_service_protocol = 'http',
  $keystone_service_host = '127.0.0.1',
  $keystone_service_port = '5000',
  $keystone_auth_host = '127.0.0.1',
  $keystone_auth_port = '35357',
  $keystone_auth_protocol = 'http',
  $keystone_auth_uri = 'http://127.0.0.1:5000/',
  $keystone_admin_token = 'ADMIN',
  $api_flavor = '',
  $registry_flavor = ''
) {

  if $api_flavor == 'keystone' or $api_flavor == 'keystone+caching' or $api_flavor == 'keystone+cachemanagement' or $registry_flavor == 'keystone' {
    package { 'python-keystone': ensure => 'present' }
  }

  file { '/etc/glance/':
    ensure  => directory,
    owner   => 'glance',
    group   => 'root',
    mode    => 770,
    require => Package['openstack-glance']
  }

  package { 'openstack-glance': ensure => $package_ensure }
  package { 'python-migrate': ensure => 'present' }

}
