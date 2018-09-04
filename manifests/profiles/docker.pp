class jenkins_ci_setup::profiles::docker (
  String $user = $jenkins_ci_setup::profiles::jenkins::user
) {

  class { 'docker':
    #tcp_bind => $listen_ip,
    # log_driver => 'gelf'
    log_driver => 'journald',
    dns => [ "8.8.8.8", "9.9.9.9" ],
    socket_group => 'adm'
  }

#
#   #file { '/usr/local/sbin/docker-gc':
#   #   ensure         => present,
#   #   owner          => 'root',
#   #   group          => 'root',
#   #   mode           => '0755',
#   #   backup         => false,
#   #   source         => 'https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc',
#   #   checksum       => 'md5',
#   #   checksum_value => '416b7040ae62860e2c4685e4fc50e1fa',
#   #}
#
#   exec { 'download-/usr/local/sbin/docker-gc':
#     command =>
#       "/usr/bin/wget -q https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc -O /usr/local/sbin/docker-gc"
#     ,
#     creates => "/usr/local/sbin/docker-gc",
#   } ->
#   file { '/usr/local/sbin/docker-gc':
#     mode => '0755',
#   }
#
#   file { '/etc/sudoers.d/docker-gc':
#     ensure  => present,
#     owner   => 'root',
#     group   => 'root',
#     mode    => '0644',
#     content => "
# $user ALL = NOPASSWD:/usr/local/sbin/docker-gc
#       "
#   }

}

