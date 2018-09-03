# == Class: puppet-jenkins_ci_setup::init
#
class puppet-jenkins_ci_setup{

  ## ressource ordering
  class { '::puppet-jenkins_ci_setup2':} ->
  class { '::puppet-jenkins_ci_setup::profiles::lighttpd':}

  ## needed ressources
  include ::puppet-jenkins_ci_setup2
  include ::puppet-jenkins_ci_setup::profiles::lighttpd
}
