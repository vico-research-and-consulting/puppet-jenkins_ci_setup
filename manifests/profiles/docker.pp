class jenkins_ci_setup::profiles::docker (
  String $user = $jenkins_ci_setup::profiles::jenkins::user
) {

  class { 'docker':
    #log_opt =>  [ 'syslog-address=unixgram:///run/systemd/journal/syslog', 'syslog-facility=daemon' ],
    #log_driver => 'syslog',
    log_driver    => 'journald',
    dns           => [ "8.8.8.8", "9.9.9.9" ],
    docker_users  => [ 'jenkins', ],
    require       => Class['jenkins'],
    socket_group  => 'adm',
    manage_kernel => false,
  }
  # docker-gc fetched from: https://github.com/spotify/docker-gc/docker-gc
  # https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc
  file { '/usr/local/sbin/docker-gc':
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0755",
    source => 'puppet:///modules/jenkins_ci_setup/docker-gc',
  }
  file { '/etc/cron.d/docker-gc':
    ensure  => file,
    owner   => "root",
    group   => "root",
    mode    => "0644",
    content => "
0 */8 * * * root /usr/local/sbin/docker-gc 2>&1 |logger -t docker-gc
      "
  }
}
