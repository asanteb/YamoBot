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


new_test = ListScraper.new
   #|username| |*slug| |members| |hours| |auto_DM?| |message| |include_greeting?| |Update Scraper automatically?|
   #Default Greeting is 'Hi |Firstname|,'
new_test.configure_list "yamoshoto", "GF", "5000", "2", true, 'Lemons', true, true
new_test.start_scrape