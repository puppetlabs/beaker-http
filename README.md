# beaker-http

This library is designed to assist in test scenarios where http requests to a Beaker::Host
are required. It utilizes the Faraday library to generate requests, and the [Http](lib/beaker-http/http.rb)
class is designed to be subclassed into objects that are more targeted to specific http
services running on beaker hosts.

## spec testing

Spec tests all live under the `spec` folder.  These are the default rake task, &
so can be run with a simple `bundle exec rake`, as well as being fully specified
by running `bundle exec rake test:spec:run` or using the `test:spec` task.

## acceptance testing

Acceptance testing will be added once the first few releases have been released.

