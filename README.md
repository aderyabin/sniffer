# Sniffer [![Build Status](https://travis-ci.org/aderyabin/sniffer.svg?branch=master)](https://travis-ci.org/aderyabin/sniffer) [![Gem Version](https://badge.fury.io/rb/sniffer.svg)](https://rubygems.org/gems/sniffer) [![Maintainability](https://api.codeclimate.com/v1/badges/640cb17b3d748a49653f/maintainability)](https://codeclimate.com/github/aderyabin/sniffer/maintainability)


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


<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Demo

![demo](https://github.com/aderyabin/sniffer/blob/master/assets/demo.gif?raw=true)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sniffer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sniffer

## Configuration

Sniffer default options:

```ruby
Sniffer.config do
  logger: Logger.new($stdout),
  severity: Logger::Severity::DEBUG,
  # HTTP options to log
  log: {
    request_url: true,
    request_headers: true,
    request_body: true,
    request_method: true,
    response_status: true,
    response_headers: true,
    response_body: true,
    timing: true
  },
  store: true, # save requests/responses to Sniffer.data
  enabled: false  # Sniffer disabled by default
end
```

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

You can configure capacity of storage to prevent the huge memory usage

```
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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aderyabin/sniffer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sniffer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aderyabin/sniffer/blob/master/CODE_OF_CONDUCT.md).
