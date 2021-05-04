class jenkins_ci_setup::profiles::python (
  String $pypi_settings_template = "",
  Hash $pypi_settings_config     = {},
) {
  ensure_packages(
    [ "python3-pip", "python3-dev", "virtualenv", "python3", "zlib1g-dev", ]
  )
  # https://gist.github.com/kogcyc/07c3e5d1f427c9fa6b99044d81f8ee82
  ensure_packages(['docker-compose', 'pipenv', "black", "isort", ], {
    ensure   => present,
    provider => 'pip3',
    require  => [ Package['python3-pip'], ],
  })

  apt::ppa { 'ppa:deadsnakes/ppa': }
  -> package { [ 'python3.9', ]:
    ensure => installed,
  }

  if $pypi_settings_template != "" {
    file { '/var/lib/jenkins/.pypirc':
      ensure => file,
      owner  => "jenkins",
      group  => "jenkins",
      mode   => "0644",
      content => template($pypi_settings_template),
      require => File['/var/lib/jenkins/'],
    }
  }
}
