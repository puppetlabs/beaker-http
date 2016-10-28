# beaker-http

This library adds the ability to send http traffic from the beaker coordinator itself,
reducing the need to use beaker's DSL method `on` as an interface to `curl` on a 
SUT(System Under Test). It utilizes the Faraday library to generate requests, and the
[Connection](lib/beaker-http/http.rb) class in the `Beaker::Http` module is the class 
you want to use directly, either utilizing it directly or subclassing it to build your
own Connection class.

Please use the DSL methods included in this library [here](lib/beaker-http/dsl/web_helpers.rb).
Reference the [rubydocs](http://www.rubydoc.info/github/puppetlabs/beaker-http/master/Beaker/DSL/Helpers/WebHelpers) for more information on how to use these methods.


## spec testing

Spec tests all live under the `spec` folder.  These are the default rake task, &
so can be run with a simple `bundle exec rake`, as well as being fully specified
by running `bundle exec rake test:spec:run` or using the `test:spec` task.

## acceptance testing

The acceptance folder currently contains [one acceptance test](acceptance/tests/puppetserver_requests.rb)
that demonstrates how to use this in a beaker test; as we refine this module and solidify the
API, more thorough acceptance testing will be coming. For now, please use that test as an example
of how to use this library.

