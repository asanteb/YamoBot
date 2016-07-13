require 'rubygems'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

load 'config/config-oauth.rb'
load 'lib/tls.rb'
load 'lib/blueprints.rb'
load 'lib/favorites.rb'
load 'lib/tweet.rb'
load 'lib/message.rb'
load 'lib/follow.rb'
load 'lib/lists.rb'
load 'lib/listscraper.rb'
load 'lib/user.rb'

test = User.new
obj = test.get_object(nil,'yamoshoto')

obj = JSON.parse(obj.body)

puts obj