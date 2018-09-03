# This file is only used for testing purposes

##################################################
#### MOCK CLASSES WHICH SHOULD NOT TESTED HERE
class puppet-jenkins_ci_setup2(
  Hash $config = {},
) {
  notice( 'mocked class ==> puppet-jenkins_ci_setup::foobar' )
}

# INCLUDE THE CLASS
include ::puppet-jenkins_ci_setup

