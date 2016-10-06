require 'beaker-http'

test_name 'Ensure that requests can be built out to the puppetserver' do

  step 'install latest released puppet agent' do
    install_puppet_agent_on(hosts)
  end

  step 'install the latest puppet-server on the master' do
    install_package(master, 'puppetserver')
    on master, 'service puppetserver start'
  end

  step 'generate a new beaker http connection object'
  http_connection = generate_new_http_connection(master)

  step 'configure the connection to connect to the master port' do
    http_connection.url_prefix.port = 8140
  end

  step 'call the environments endpoint on the puppetserver' do
    response = http_connection.get('/puppet/v3/environments')
    assert_equal(200, response.status)
  end

  step 'call the environments endpoint with the #https_request method' do
    response = http_request("https://#{master.hostname}:8140/puppet/v3/environments",
      :get,
      http_connection.ssl['client_cert'],
      http_connection.ssl['client_key'])
    assert_equal(200, response.status)
  end
end
