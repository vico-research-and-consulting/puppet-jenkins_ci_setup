#----------------------------------------------------------------------
# instantiating testing requirements
#----------------------------------------------------------------------

if (!ENV['w_ssh'].nil? && ENV['w_ssh'] = 'true')
  begin
    require 'spec_helper.rb'
  rescue LoadError
  end
else
  begin
    require 'spec_helper.rb'
    set :backend, :exec
  rescue LoadError
  end
end
#----------------------------------------------------------------------

#  http://serverspec.org/resource_types.html

#----------------------------------------------------------------------
# testing basic service
#----------------------------------------------------------------------
describe package('haproxy') do
  it { should be_installed }
end

describe service('haproxy') do
  it { should be_enabled }
end

describe service('haproxy') do
  it { should be_running }
end

describe port(80) do
   it { should be_listening.on('0.0.0.0').with('tcp') }
end

describe port(443) do
   it { should be_listening.on('0.0.0.0').with('tcp') }
end


#----------------------------------------------------------------------
# testing basic function
#----------------------------------------------------------------------

describe command('curl -vvv -k "http://127.0.0.1/" 2>&1 | grep Location') do
     its(:stdout) { should match /Location: https:\/\// }
end

describe command('curl -k "https://127.0.0.1/" 2>&1') do
     its(:stdout) { should match /Authentication required/ }
end


#----------------------------------------------------------------------

