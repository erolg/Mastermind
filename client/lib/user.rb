require 'uri'
require 'net/http'
require 'httparty'
require 'json'


class User
  def initialize(output)
    @output = output
  end

  def register
    http = Net::HTTP.new('localhost', 3000)
    path = '/register'
    resp, data = http.get(path, nil)
    @cookie = resp.response['set-cookie'].split('; ')[0]
  end

  def give_feedback(guess)

    post_data = 'guess[]='+guess[0]+','+guess[1]+','+guess[2]+','+guess[3]

    http = Net::HTTP.new('localhost', 3000)

    headers = {
      'Cookie' => @cookie,
      'Content-Type' => 'application/x-www-form-urlencoded'
    }

    path = '/play'
    resp, data = http.post(path, post_data, headers)


    json = JSON.parse(resp.body)



    correct = json["Indicator"]["correct"]
    close = json["Indicator"]["close"]

    
    return [correct, close]
  end
end
