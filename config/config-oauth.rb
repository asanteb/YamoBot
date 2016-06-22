require 'rubygems'
require 'oauth'

file = File.read(File.expand_path('config/settings.json')) #Reads configuration file
$settings = JSON.parse(file) #Collects configurations and creates a hash to global variable $settings

class USER_OAUTH

  def getConsumerKey # getter method for collecting two consumer keys - consumer key and consumer secret

    bool = $settings["local_keys"] #Collects configuration hash to see if we should
                                   # use temperary keys or locally stored keys

    #These if statements compares hash configuration from bool to actual T & F
    filename = "keys/auth.temp"  if bool == false #filename will then be changed to the correct key file
    filename = "keys/local.keys" if bool == true

    #opens keyfile and inserts each line(four) into an array(auth)
      auth = Array.new
      f = File.readlines(filename)
      f.each do |line|
      auth << line.strip
      end

    @consumer_key = OAuth::Consumer.new(auth[0], auth[1]) #first two elements are for consumer/ last 2 tokens
                                                          #creates and returns consumer_key using oauth gem
  end

  def getAccessToken # getter method for collecting two access tokens - user token and access secret

    bool = $settings["local_keys"]

    filename = "keys/auth.temp" if bool == false
    filename = "keys/local.keys" if bool == true

    auth = Array.new
    f = File.readlines(filename)
    f.each do |line|
      auth << line.strip
    end

    @access_token = OAuth::Token.new(auth[2], auth[3]) #creates and returns consumer_key using oauth gem
  end
end
