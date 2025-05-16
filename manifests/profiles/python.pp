class jenkins_ci_setup::profiles::python (
  String $pypi_settings_template = "",
  Hash $pypi_settings_config     = {},
) {
  ensure_packages(
    # TODO make sure this gets updated
    [ "python3-pip", "python3-dev", "python3", "zlib1g-dev", "lzma", "liblzma-dev", "libssl-dev", "libsqlite3-dev", "tk-dev", "libgdbm-dev", "libc6-dev", "libbz2-dev", "libffi-dev", "zlib1g-dev"]
  )
  # https://gist.github.com/kogcyc/07c3e5d1f427c9fa6b99044d81f8ee82
  ensure_packages(['docker-compose', 'pipenv', "black", "isort", "twine" ], {
    ensure   => present,
    provider => 'pip3',
    require  => [ Package['python3-pip'], ],
  })

  package { [ "software-properties-common", ]:
    # shouldn't apt::ppa require this? needed for add-apt-repository
    ensure => installed,
  }
  -> apt::ppa { 'ppa:deadsnakes/ppa': }
  -> package { [ 'python3.9', "python3.9-distutils" ]:
    ensure => installed,
  }

  if $pypi_settings_template != "" {
    file { '/var/lib/jenkins/.pypirc':
      ensure  => file,
      owner   => "jenkins",
      group   => "jenkins",
      mode    => "0640",
      content => template($pypi_settings_template),
      require => File['/var/lib/jenkins/'],
    }
  }
}
