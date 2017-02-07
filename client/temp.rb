require 'uri'
require 'net/http'
require 'httparty'
require 'json'

http = Net::HTTP.new('localhost', 3000)
http.use_ssl = false
path = '/register'

# GET request -> so the host can set his cookies
resp, data = http.get(path, nil)
cookie = resp.response['set-cookie'].split('; ')[0]


# POST request -> logging in
data = 'guess[]=red,green,orange,blue'
headers = {
  'Cookie' => cookie,
  'Content-Type' => 'application/x-www-form-urlencoded'
}

path = '/play'
resp, data = http.post(path, data, headers)


json = JSON.parse(resp.body)

puts json["Found"]
