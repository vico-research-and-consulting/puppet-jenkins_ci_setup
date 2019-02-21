Overview
--------

This module installs a almost ready to use jenkins setup for corporated needs.

Resources
---------

 * this project is based/located on https://github.com/scoopex/puppet-puppet-jenkins_ci_setup
 * test kitchen: 
   * http://kitchen.ci/
   * https://docs.chef.io/kitchen.html
   * https://github.com/test-kitchen/test-kitchen
   * https://docs.chef.io/config_yml_kitchen.html
   * https://docs.chef.io/plugin_kitchen_vagrant.html
   * https://github.com/neillturner/kitchen-puppet/blob/master/provisioner_options.md
 * serverspec tests
  * resources : http://serverspec.org/resource_types.html
 * puppet modules: https://forge.puppet.com/
 * puppet FAQ: https://ask.puppet.com/question/32373/is-there-a-document-on-how-to-setup-test-kitchen-with-puppet/
 * misc
  * https://de.slideshare.net/MartinEtmajer/testdriven-infrastructure-with-puppet-test-kitchen-serverspec-and-rspec
  * http://ehaselwanter.com/en/blog/2014/05/08/using-test-kitchen-with-puppet/
  * https://apache.googlesource.com/infrastructure-puppet-kitchen/
 * Librarian: http://librarian-puppet.com/

TODO
----

 * Improve documentation
   * Configsync
 * Secure HAPROXY
   ```
   ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
   ssl-default-bind-options no-sslv3
   ```


How to use it
------------------------------------

  * Assign the role/the module "jenkins_ci_setup" to the node 
  * Register a dns entry for this setup, i.e. jenkins.mycompany.com
  * Run puppet on the target system and wait for completion
  * Gather start password for the "admin" user.
    ```
    $ grep -A 2 "Please use the following password to proceed to installation:" /var/log/jenkins/jenkins.log 
    Please use the following password to proceed to installation:

    c2241482815255368i9992aaaffaaffa
    ```
  * Install suggested plugins
  * Invoke jenkins web ui: https://<dns-name>/
  * Change password of "admin" user
  * Get the public key of automatically generated ssh keypair
    ```
    cat /var/lib/jenkins/.ssh/id_rsa.pub
    ```
  * Active config backup
    * Create a jenkins-config repo at gitlab
    * add public key to the repo as deployment key with write permissions</br>
      (Settings -> Repository -> Deployment Keys -> Add key and hook "Write access allowed"
    * Approve SSH Key
      ```
      cd /tmp
      git clone <repourl>
      ```
  * Active Directory Config
    * Manage Jenkins -> Configure Global Security
    * Hook: Enable security
    * Select:  Active Directory -> Add domain
    * Domainname: foo.local
    * Domain controller: <ip> <ip>:<port>
    * Bind DN: Jenkins
    * Bind Password: <password>
    * Execute "Test Domain"A
  * Authorization
    * Matrix-based security 
    * Add Ad groups
      * Authenticated Users : JOB - Build Cancel, Configure, Read, Workspac; View: Read
      * Developer Grous: Everything
  * Manage access to alle systems 
    * Get the public key:
      ```
      ssh jenkins
      cat /var/lib/jenkins/.ssh/id_rsa.pub
      ```
    * Add the ssh public key to all target systems (jenkins slaves, remote execution servers - ideally using puppet)
      ```
      ssh <hostname>
      useradd -m jenkins -G docker -s /bin/bash
      mkdir ~jenkins/.ssh
      echo "ssh-rsa ..." >> ~jenkins/.ssh/authorized_keys
      chown -R jenkins:jenkins ~jenkins/.ssh/
      chmod 700 ~jenkins/.ssh/
      chmod 600 ~jenkins/.ssh/authorized_keys
      ```
    * Approve the ssh keypair of the target system
      ```
      ssh <jenkins-server>
      su - jenkins
      ssh <hostname>
      ```
   * Configure System
      * Create a config git repo and grant access to the /var/lib/jenkins/.ssh/id_rsa.pub key
      * Approve key
        ```
        ssh gitlab-server
        -> yes
        ```
      * SCM Sync configuration
        * Git
        * Add repo: git@<gitlab-server>:<repo>/jenkins-config.git
        * No error message should occur</br>
          (if footer displays error messages, delete /var/lib/jenkins/scm-sync-configuration.fail.log)
      * Jenkins Location:
         * Configure "Jenkins URL" and "System Admin e-mail address"
      * Maven Scheduled Repository Cleaner
         * "H 7 * * *"
      * Extended E-mail Notification
         * SMTP server: <server>
         * Default user E-mail suffix: <domain>
         * Reply To List: <Admin Mail>
      * E-mail Notification
        * SMTP server: <server>
        *	Default user e-mail suffix: @<domain>
        * ...

  

How to start:
------------------------------------

  * Install virtualbox: https://www.virtualbox.org/wiki/Linux_Downloads
  * Installation of vagrant
   * see: https://www.vagrantup.com/downloads.html
   * Download und Installation
     ```
     cd /tmp
     wget https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.deb
     sudo dpkg -i vagrant_*_x86_64.deb
     ```
  * Clone the repo
    ```
    git clone https://github.com/scoopex/puppet-puppet-jenkins_ci_setup.git
    cd puppet-puppet-jenkins_ci_setup
    ```
  * Installation of RVM
     * Follow the offical installation procedure at https://rvm.io/, i.e.:
       ```
       gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
       \curl -sSL https://get.rvm.io | bash -s stable
       # source this or add this to your .bashrc
       source ~/.rvm/scripts/rvm
       exec bash
       # asks for root password and installs packages like libyaml-dev, libsqlite3-dev, libgdbm-dev, libncurses5-dev, bison, libreadline6-dev
       rvm install "ruby-2.4.1"
       ```
     * Configuration of RVM<br>
       After the rvm installtion a configuration file (~/.rvmrc) should be created with the following content:
       ```
       echo "rvm_autoinstall_bundler_flag=1" >> ~/.rvmrc
       apt install ruby-dev libgmp-dev
       gem install bundler
       # Now the automatic invocation of bundler should install all the missing gems
       cd ..; cd puppet-puppet-jenkins_ci_setup
       ```
       This allows the convinient automatic installation of bundler.

     * Install Ruby, work with control repositories
       There are numerous possibilities to work with RVM - we are unsing the Gemfile procedure.
       see: Gemfile
       ```
       source 'https://rubygems.org'

       #ruby=2.0.0-p645
       #ruby-gemset=puppet-testing

       (...)
       ```
       The entries with the leading hashes (#) are not disabled entries. You have to install the configured ruby release in a manual procedure.
       You will get a notification "Required ruby-2.4.1 is not installed." if this step is missing.

       "test-kitchen": Serverspec Test mit Vagrant/Virtualbox/Docker

Cheat Sheet
-----------

```
Command                              Description
------------------------------------------------------------------------
kitchen list                         View all test suites
kitchen create                       Create the target system (Vagrant)
kitchen create <suite>
kitchen converge <suite>             Execute puppet (Puppet)
kitchen login <suite>                SSH Login
kitchen verify <suite>               Execute test suites (servespec)
kitchen test <suite>                 Create, test and destroy system
kitchen destroy                      Destroy all test systems
kitchen destroy <suite>              Destroy a certain test system

kitchen verify -l debug              Get enhanced debug information

librarian-puppet install --verbose   Debug librarian problems
------------------------------------------------------------------------
```

Instance selection/handling:

* Use "kitchen list" to identify instances
* Add the full name of the instances to a certain command
   * Kitches selects instances by regex matches, so think about naming schemes
   * If you do not specify a regex ".*" is automatically assumed
* Kitchen automatically create all permutations of suites and platforms, see .kitchen.yml


Develop and test puppet code
-------------------------------

 * Change to the directory
   ```
   cd puppet-puppet-jenkins_ci_setup
   ```
 * Reset the environment<br>
   (if you want to revert everything)
   ```
   kitchen destroy
   rm -rf Gemfile.lock Puppetfile.lock .kitchen .librarian/ .tmp/
   ```
 * Add Puppet modules and edit sourcecode
   ```
   vim Puppetfile 
   vim manifests/* 
   vim test/integration/default/serverspec/*
   ```
 * Deploy a test system and login to the system for debugging purposes
   ```
   kitchen list
   kitchen create <instance>
   kitchen login <instance>
      sudo bash
   ```
 * Execute puppet withe the current code
   ```
   kitchen converge <instance>
   ```
 * Execute serverspec tests
   ```
   kitchen verify <instance>
   ```
 * Destroy environment
   ```
   kitchen destroy <instance>
   ```


Contribution
------------

 * file a bug on the github project: https://github.com/scoopex/puppet-puppet-jenkins_ci_setup/issues
 * fork the project and improve the template
 * create a pull/merge request


TODO
----

Load Start config by https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/README.md
CASC_JENKINS_CONFIG="jenkins.yaml"
