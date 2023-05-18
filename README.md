# Sniffer

[![Build](https://github.com/aderyabin/sniffer/workflows/Run%20Tests/badge.svg)](https://github.com/aderyabin/sniffer/actions) [![Gem Version](https://badge.fury.io/rb/sniffer.svg)](https://rubygems.org/gems/sniffer) [![Join the chat at https://gitter.im/aderyabin/sniffer](https://badges.gitter.im/aderyabin/sniffer.svg)](https://gitter.im/aderyabin/sniffer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Sniffer aims to help:

  * Log outgoing HTTP requests. Sniffer logs as JSON format for export to ELK, Logentries and etc.
  * Debug requests. Sniffer allows to save all requests/responses in storage for future debugging

Sniffer supports most common HTTP accessing libraries:

* [Net::HTTP](http://ruby-doc.org/stdlib-2.4.2/libdoc/net/http/rdoc/Net/HTTP.html)
* [HTTP](https://github.com/httprb/http)
* [HTTPClient](https://github.com/nahi/httpclient)
* [Patron](https://github.com/toland/patron)
* [Curb](https://github.com/taf2/curb/)
* [Ethon](https://github.com/typhoeus/ethon)
* [Typhoeus](https://github.com/typhoeus/typhoeus)
* [EM-HTTP-Request](https://github.com/igrigorik/em-http-request)
* [Excon](https://github.com/excon/excon)

## Demo

![demo](https://github.com/aderyabin/sniffer/blob/master/assets/demo.gif?raw=true)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sniffer'
```

If you wish Sniffer to use `Module#prepend` instead of `alias_method`, you can cause individual adapters to use `prepend` instead with:

```ruby
gem 'sniffer', require: ['http_prepend', 'httpclient_prepend', 'sniffer']
```

It's important that `'sniffer'` is the last item in the list. See the `lib` directory for a list of prependable adapters.

If you want all adapters to use `prepend`:

```ruby
gem 'sniffer', require: ['all_prepend', 'sniffer']
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sniffer

## Usage

Here's some simple examples to get you started:

```ruby
require 'http'
require 'sniffer'

Sniffer.enable!

HTTP.get('http://example.com/?lang=ruby&author=matz')
Sniffer.data[0].to_h
# => {:request=>
#   {:host=>"example.com",
#    :query=>"/?lang=ruby&author=matz",
#    :port=>80,
#    :headers=>{"Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Connection"=>"close"},
#    :body=>"",
#    :method=>:get},
#  :response=>
#   {:status=>200,
#    :headers=>
#     {"Content-Encoding"=>"gzip",
#      "Cache-Control"=>"max-age=604800",
#      "Content-Type"=>"text/html",
#      "Date"=>"Thu, 26 Oct 2017 13:47:00 GMT",
#      "Etag"=>"\"359670651+gzip\"",
#      "Expires"=>"Thu, 02 Nov 2017 13:47:00 GMT",
#      "Last-Modified"=>"Fri, 09 Aug 2013 23:54:35 GMT",
#      "Server"=>"ECS (lga/1372)",
#      "Vary"=>"Accept-Encoding",
#      "X-Cache"=>"HIT",
#      "Content-Length"=>"606",
#      "Connection"=>"close"},
#    :body=> "OK",
#    :timing=>0.23753299983218312}}
```

You can clear saved data

```
Sniffer.clear!
```

You can configure capacity of storage to prevent the huge memory usage and set up log rotation.
By default log rotation is active (when capacity is set) and log works like a queue.
If rotation is disabled - requests will be logged until result log size reaches the capacity.

```
# will fill the storage and stop logging
Sniffer.config.store = {capacity: 1000, rotate: false}

# will rotate logs to fit 1000 results (rotate is true by default)
Sniffer.config.store = {capacity: 1000}
```

You can reset config to default

```
Sniffer.reset!
```

You can enable and disable Sniffer

```
Sniffer.enable!
Sniffer.disable!
```

By default output log looks like that:

```
D, [2017-10-26T16:47:14.007152 #59511] DEBUG -- : {"port":80,"host":"example.com","query":"/?lang=ruby&author=matz","rq_connection":"close","method":"get","request_body":"","status":200,"rs_accept_ranges":"bytes","rs_cache_control":"max-age=604800","rs_content_type":"text/html","rs_date":"Thu, 26 Oct 2017 13:47:13 GMT","rs_etag":"\"359670651+gzip\"","rs_expires":"Thu, 02 Nov 2017 13:47:13 GMT","rs_last_modified":"Fri, 09 Aug 2013 23:54:35 GMT","rs_server":"ECS (lga/1385)","rs_vary":"Accept-Encoding","rs_x_cache":"HIT","rs_content_length":"1270","rs_connection":"close","timing":0.513012999901548,"response_body":"OK"}
```
where `rq_xxx` is request header and `rs_xxx` - response header

## Configuration

Sniffer default options:

```ruby
Sniffer.config do |c|
  c.logger = Logger.new($stdout)
  c.severity = Logger::Severity::DEBUG
  # HTTP options to log
  c.log = {
    request_url: true,
    request_headers: true,
    request_body: true,
    request_method: true,
    response_status: true,
    response_headers: true,
    response_body: true,
    timing: true
  }
  c.store =  true # save requests/responses to Sniffer.data
  c.enabled = false  # Sniffer disabled by default
  c.url_whitelist = nil
  c.url_blacklist = nil
end
```

### Whitelist

You can add specific host url to whitelist as regexp or string. Sniffer will store only requests that matched.

```ruby
Sniffer.config.url_whitelist = /whitelisted.com/

HTTP.get('http://example.com')
Sniffer.data[0].to_h
# => {}

HTTP.get('http://whitelisted.com/')
Sniffer.data[0].to_h
# => {{:request=>{:host=>"whitelisted.com", ....}}
```

### Blacklist

You can add specific host url to blacklist as regexp or string. Sniffer will ignore all matched requests.

```ruby
Sniffer.config.url_blacklist = /blacklisted.com/

HTTP.get('http://blacklisted.com')
Sniffer.data[0].to_h
# => {}

HTTP.get('http://example.com')
Sniffer.data[0].to_h
# => {{:request=>{:host=>"example.com", ...}}
```

### Middleware

You can add the middleware to run custom code before/after the sniffed data was logged.

```ruby
Sniffer.middleware do |chain|
  chain.add MyHook
end

class MyHook
  def request(data_item)
    puts "Before work"
    yield
    puts "After work"
  end

  def response(data_item)
    puts "Before work"
    yield
    puts "After work"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Development (with Docker)

Get local development environment working and tests running is very easy with docker-compose:
```sh
docker-compose run app bundle
docker-compose run app bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aderyabin/sniffer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Acknowledge

* [Sergey Ponomarev](https://github.com/sponomarev)
* [Vladimir Dementyev](https://github.com/palkan)
* [Salahutdinov Dmitry](https://github.com/dsalahutdinov)
* [Stanislav Chereshkevich](https://github.com/dissident)
* [Anatoliy Kurichev](https://github.com/russo-matrosso)
* [Dmitriy Ivliev](https://github.com/moofkit)
* [Nate Berkopec](https://github.com/nate-at-gusto)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sniffer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aderyabin/sniffer/blob/master/CODE_OF_CONDUCT.md).
