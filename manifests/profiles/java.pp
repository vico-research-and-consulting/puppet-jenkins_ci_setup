class jenkins_ci_setup::profiles::java (
    String $maven_settings_template = "",
    Hash $maven_settings_config     = {},
) {
  package{ "maven": }

  jenkins::plugin { 'maven-plugin': }
  jenkins::plugin { 'm2release': }
  jenkins::plugin { 'javadoc': }
  jenkins::plugin { 'pipeline-maven': }
  jenkins::plugin { 'maven-repo-cleaner': }
  jenkins::plugin { 'gradle': }
  jenkins::plugin { 'jacoco': }

  file { '/var/lib/jenkins/.m2/':
    ensure => directory,
    owner  => "jenkins",
    group  => "jenkins",
    mode   => "0755",
  }
  if $maven_settings_template != "" {
    file { '/var/lib/jenkins/.m2/settings.xml':
      ensure => file,
      owner  => "jenkins",
      group  => "jenkins",
      mode   => "0644",
      source => $maven_settings_template, 
      require => File['/var/lib/jenkins/.m2/'],
    }
  }
}

