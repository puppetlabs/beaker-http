require 'beaker-http'

test_name 'Ensure that requests can be built out to the puppetserver'

step 'install latest released puppet agent' do
  install_puppet_agent_on(hosts)
end

step 'install the latest puppet-server on the master' do
  install_package(master, 'puppetserver')
  on master, 'service puppetserver start'
end

step 'generate a new beaker http connection object'
beaker_http_connection = Beaker::Http::Connection.new(master)

step 'configure the connection to connect to the master port'
beaker_http_connection.connection.port = 8140

step 'configure ssl for the connection'
beaker_http_connection.configure_private_key_and_cert_with_puppet

step 'call the environments endpoint on the puppetserver' do
  response = beaker_http_connection.get('/puppet/v3/environments')
  assert_equal(200, response.status)
end
