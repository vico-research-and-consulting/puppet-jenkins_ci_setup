class jenkins_ci_setup::profiles::java (
    String $maven_settings_template = "",
    Hash $maven_settings_config     = {},
    String $java_package_extra      = "openjdk-11-jdk",
) {
  class { "maven::maven":
    version => "3.8.2",
  }

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
      mode   => "0640",
      content => template($maven_settings_template),
      require => File['/var/lib/jenkins/.m2/'],
    }
  }

  if $java_package_extra {
    package{$java_package_extra:
      ensure => present,
    }

    exec { 'update-java-alternatives -s java-1.8.0-openjdk-amd64 -v':
        path      => '/usr/local/sbin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
        user      => 'root',
        logoutput => true,
        unless    => 'java -version 2>&1 |grep -P \'^openjdk version "1.8.\d+_\d+"\'',
        require   => Package[$java_package_extra],
    }
  }
}

