module Responses
  POST_URL = 'http://localhost:4567/data'
  GET_URL = 'http://localhost:4567'

  def get_response
    {
      request: {
        url: '/',
        headers: { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                   "accept" => "*/*",
                   "user-agent" => "Ruby",
                   "connection" => "close" },
        body: nil,
        method: 'GET',
        ssl: false,
        port: 4567
      },
      response: {
        headers: { "content-type" => "text/html;charset=utf-8",
                   "x-xss-protection" => "1; mode=block",
                   "x-content-type-options" => "nosniff",
                   "x-frame-options" => "SAMEORIGIN",
                   "connection" => "close",
                   "content-length" => "2" },
        body: 'OK',
        status: "200"
      }
    }
  end

  def post_response
    {
      request: {
        url: '/data',
        headers: { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                   "accept" => "*/*",
                   "user-agent" => "Ruby",
                   "content-type"=>"application/x-www-form-urlencoded",
                   "connection" => "close" },
        body: "lang=Ruby&author=Matz",
        method: 'POST',
        ssl: false,
        port: 4567
      },
      response: {
        headers: { "content-type" => "text/html;charset=utf-8",
                   "x-xss-protection" => "1; mode=block",
                   "x-content-type-options" => "nosniff",
                   "x-frame-options" => "SAMEORIGIN",
                   "connection" => "close",
                   "content-length" => "7" },
        body: 'Created',
        status: 201
      }
    }
  end

   module_function :get_response, :post_response
end
