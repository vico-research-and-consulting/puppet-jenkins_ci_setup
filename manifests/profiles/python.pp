class jenkins_ci_setup::profiles::python (
    String $maven_settings_template = "",
    Hash $maven_settings_config     = {},
) {
  ensure_packages(
      [ "python3-pip", "python3-dev", "virtualenv", "python3", "zlib1g-dev", 
      ]
  )
 # https://gist.github.com/kogcyc/07c3e5d1f427c9fa6b99044d81f8ee82
  ensure_packages(['docker-compose', 'pipenv' ], {
         ensure   => present,
         provider => 'pip3',
         require  => [ Package['python3-pip'], ],
  })
}

