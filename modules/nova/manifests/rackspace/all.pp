# TODO - this is currently hardcoded to be a xenserver

#
# this will be specific to how rackspace composes 
#  the various backends for openstack
#
class nova::rackspace::all(
  $verbose = 'true',
  $db_password,
  $db_name = 'nova',
  $db_user = 'nova',
  $db_host = 'localhost',
  $image_service = 'nova.image.glance.GlanceImageService',
  $flat_network_bridge = 'xenbr0',
  $flat_network_bridge_ip = '10.0.0.1',
  $flat_network_bridge_netmask = '255.255.255.0',
  $glance_api_servers = 'localhost:9292',
  $allow_admin_api = 'true',
  $rabbit_host = undef,
  $rabbit_port = undef,
  $rabbit_userid = undef,
  $rabbit_password = undef,
  $rabbit_virtual_host='/',
  $service_down_time='180000000',
  $quota_instances='1000000',
  $quota_cores='1000000',
  $quota_volumes='1000000',
  $quota_gigabytes='1000000',
  $quota_floating_ips='1000000',
  $quota_metadata_items='1000000',
  $quota_max_injected_files='1000000',
  $quota_max_injected_file_content_bytes='1000000',
  $quota_max_injected_file_path_bytes='1000000',
  $host,
  $xenapi_connection_password,
  $xenapi_connection_url = 'localhost',
  $xenapi_connection_username = 'nova',
  $xenapi_inject_image = 'false'
) {


  # this is rackspace specific stuff for setting up the repos
  # most of this code may go away after they are finished
  # developing
  stage { 'repo-setup':
    before => Stage['main'],
  }
  class { 'apt':
    disable_keys => true,
    #always_apt_update => true,
    stage => 'repo-setup',
  }
  class { 'nova::rackspace::repo':
   stage => 'repo-setup',
  }
  class { 'mysql::server':
    root_password => 'password'
  }
  class { 'nova::rabbitmq':
    port         => $rabbit_port,
    userid       => $rabbit_userid,
    password     => $rabbit_password,
    virtual_host => $rabbit_virtual_host,
  }
  #class { 'nova::rackspace::dev': }

  class { "nova":
    verbose              => $verbose,
    sql_connection       => "mysql://${db_user}:${db_password}@${db_host}/${db_name}",
    image_service        => $image_service,
    glance_api_servers   => $glance_api_servers,
    allow_admin_api      => $allow_admin_api,
    rabbit_host          => $rabbit_host,
    rabbit_password      => $rabbit_password,
    rabbit_port          => $rabbit_port,
    rabbit_userid        => $rabbit_userid,
    rabbit_virtual_host  => $rabbit_virtual_host,
    service_down_time    => $service_down_time,
  }

  class { 'nova::quota':
    quota_instances      => $quota_instances,
    quota_cores          => $quota_cores,
    quota_volumes        => $quota_volumes,
    quota_gigabytes      => $quota_gigabytes,
    quota_floating_ips   => $quota_floating_ips,
    quota_metadata_items => $quota_metadata_items,
    quota_max_injected_files              => $quota_max_injected_files,
    quota_max_injected_file_content_bytes => $quota_max_injected_file_content_bytes,
    quota_max_injected_file_path_bytes    => $quota_max_injected_file_path_bytes,
  }

  class { "nova::api": enabled => true }
  class { "nova::compute::xenserver":
    host                       => $host,
    xenapi_connection_url      => $xenapi_connection_url,
    xenapi_connection_username => $xenapi_connection_username,
    xenapi_connection_password => $xenapi_connection_password,
    xenapi_inject_image        => $xenapi_inject_image,
    api_server                 => '127.0.0.1',
    enabled                    => true
  }
  class { "nova::network::flat":
    enabled => true,
    flat_network_bridge => $flat_network_bridge,
    flat_network_bridge_ip => $flat_network_bridge_ip,
    flat_network_bridge_netmask => $flat_network_bridge_netmask,
    configure_bridge => false,
  }
  class { "nova::objectstore": enabled => false }
  class { "nova::scheduler": enabled => true }
  class { 'nova::db':
    # pass in db config as params
    password => $db_password,
    dbname   => $db_name,
    user     => $db_user,
    host     => $db_host,
  }
}
