# Bullet Train HTTP Filter

HTTP security is hard, especially when you're giving your users the power to call HTTP
endpoints from within your application.

This gem implements two things:

* A URI parser that can detect dangerous things like domain names that point at local resources
* An Excon middleware that uses the above URI filter to reject requests that are not allowed

