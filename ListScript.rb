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

#=begin
class ListScript
  def setup_automation your_screen_name, slug, mem_num
    puts 'Commencing setup'
    @screen_name = your_screen_name
    @users = []
    @follows_hash = {}
    @did_dm = {}
    @firstname = []
    @super_count = Integer(mem_num)

    test = List.new

    obj = test.getList_members slug, your_screen_name, mem_num
    obj = JSON.parse(obj.body)

    count = obj['users'].count


    i = 0
    while i < count do
      @users.insert(i, obj['users'][i]['screen_name'])
      puts "Setting up for: #{@users[i]}"
      @follows_hash["#{@users[i]}"] = false
      @did_dm["#{@users[i]}"] = false
      @firstname.insert(i, obj["users"][i]["name"].split(' ').first) #added first name
      i += 1
    end


    @new_follow = Follow.new
    @new_message = Message.new

    @users.each do |user|
      puts "Following #{user}"
      @new_follow.follow(nil, user, true)
    end
    puts 'Setup has completed'
  end

  def start_automation hours, message
    puts 'Starting new cycle!'
    new_follow = Follow.new
    new_message = Message.new

    hours = Integer(hours)
    i = 0; j = 0
    while i < hours do
      while j < 4 do
        puts 'Checking relationships...'
        @total = 0
        @users.each do |user|
          @obj = new_follow.check_if_following(user, @screen_name)
          @obj = JSON.parse(@obj.body)
          if @obj['relationship']['target']['following'] == true
            @follows_hash[user] = true
            @total += 1
          end

        end
      #success report

        quarter_success = (@total.to_f / @super_count.to_f) * 100.0
        puts "Percentage of followers for mini-cycle #{j+1} of 4 is: #{quarter_success}%"
      puts 'now sleeping...'
      sleep(900) #For seconds 900 = 15 minutes
      j +=  1
    end
    puts 'sending out direct messages to...'
      k = 0
    @users.each do |user|

      if @follows_hash[user] == true && @did_dm[user] == false
        puts user

        complete_message = "Hi #{@firstname[k]}%2C #{message}"
        new_message.direct_message nil, user, complete_message
        @did_dm[user] = true
      end
      k+=1
    end
    puts 'messages sent...'
    puts 'cycle completed...'
    @hourly_success = (@total.to_f / @super_count.to_f) * 100.0
    puts "hourly follower percentage #{@hourly_success}"
    i += 1
    end
    @return_success = @success
  end
end


new_script = ListScript.new
puts "Welcome to script configuration..."
puts "Enter your Twitter username:"
username = gets.chomp
puts "Next enter the list slug (aka list name), Note* slug is case sensitive"
slug = gets.chomp
puts "Finally enter the number of members in your list"
num = gets.chomp
new_script.setup_automation username, slug, num

puts "It's time to set up automation commands"
puts " Select how many hours you want to run the script"
hours = gets.chomp

puts "Type in the the message you would like to send"
puts "remember punctation has to be in HTMl hexa... ex. %2C = ',' or comma"
message = gets.chomp


new_script.start_automation hours, message
#success_data = new_script.start_automation hours, message collect percentage if wanted

=begin
firstname = new_script.get_firstname
message = "Hi #{firstname}%2C #{message}"
=end

