class ListScraper

  $redis = Redis.new #Uses default redis connection settings. Change if different


  def configure_list (your_screen_name, slug, member_num, hours, run_auto_dm, message, greeting, auto_update)


    #initiallizes most local variables into instanced class variables
    @users = {}
    @run_auto_dm = run_auto_dm # Contains instance boolean value from user
    @greeting = {} if greeting
    @auto_update = auto_update

    @slug = slug
    @hours = hours
    @member_num = member_num
    @message = message
    @screen_name = your_screen_name

    obj_e = File.read('lib/limit_error.json') #'temp_dump/list_obj.json')
    @rate_limit_error = JSON.parse(obj_e)

    client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'yamobot') #edit database and address here
    db = client.database
    @db_members = db.collection('list_members')


    list_obj = List.new
    obj = list_obj.getList_members slug, your_screen_name, member_num #initiates call to List class
    obj = JSON.parse(obj.body)  #parses object collected from List class


    count = obj['users'].count #Counts each user from the object
                               #This is collects right amount regardless if you input 5000 members

    #This loop sets up one array and two hashes.
    #@users is an instance array that is collecting screen name from twitter object
    #@follows_hash is an instance hash that has the username containing a boolean value
    #@did_dm is an instance hash that has the username containing a boolean value
    i = 0; while i < count do
          username = obj['users'][i]['screen_name']
          puts "Setting up for: #{obj['users'][i]['screen_name']}"
          @users[:"#{username}"] = username
          firstname = obj['users'][i]['name'].split(' ').first
          lastname = obj['users'][i]['name'].split(' ').last
          $redis.mapped_hmset username, { firstname: firstname, lastname: lastname, follows: false,
                                         did_dm: false, tweeted: 0 }

          #@greeting[:"#{username}"] = "Hi #{name}%2C "

          mongo_obj = {
                       :username => username,
                       :firstname => firstname,
                       :lastname => lastname,
                       :follows => false,
                       :did_dm => false,
                       :tweeted => 0
          }
          #puts mongo_obj
          puts '////////////////////CHECK_IF/////////////////////'
          check_if = @db_members.find(:username => username).first
          puts check_if
          puts '////////////////////CHECK_IF/////////////////////'

          if check_if
            $redis.mapped_hmset username , {firstname: check_if[:firstname],
                                            lastname:  check_if[:lastname],
                                            follows:   check_if[:follows],
                                            did_dm:    check_if[:did_dm],
                                            tweeted:   check_if[:tweeted]}
          end

          @db_members.insert_one(mongo_obj) if check_if == nil

          i += 1
           end

           $redis.mapped_hmset "last_num", {tweet_num: nil}

           @tweet_messages = ["We've built a platform to discover and fund cutting-edge medical research! Decide what's next: http://bit.ly/FutureOfHealth",
                              "20 years' worth of life-saving treatments sits untested! Help advance the next big research: http://bit.ly/FutureOfHealth",
                              "Help advance the latest health discoveries! Decide what should be funded next: http://bit.ly/FutureOfHealth",
                              "Discover the latest medical research and help us advance them! Enter HealthFundIt: http://bit.ly/FutureOfHealth",
                              "20 years' worth of life-saving treatments sits untested! We help fund them! Decide what's next: http://bit.ly/FutureOfHealth"
                            ]



    #Automatically follows all users in @user array
    #Possible optimization to only follow users that haven't been followed yet
    #Current implementation follows everyone in the list

    new_follow = Follow.new
    @users.each do |key, user|
      puts "Following #{user}"
      @error_check = new_follow.follow(nil, user, false)

      @error_check = JSON.parse(@error_check.body)
      escape = 0

      while escape == 0
        if @error_check != @rate_limit_error
          break
        end
        puts "API CALL LIMIT EXCEEDED"
        puts "waiting 1 minute"
        sleep(60)
        @error_check = new_follow.follow(nil, user, false)
        @error_check = JSON.parse(@error_check.body)
      end
    end
  end


  def start_scrape #Scrapes lists from initial setups

    new_follow = Follow.new #Object call to be used later for follower checks
    hours = Integer(@hours) #turns string value to integer value

    #First 'i' loop is calculated for the number of hours you want
    #This is assumed that ever 'j' loop is sleeping for 15 minutes 4 times
    #The 'j' loop is responsible for checking if a user is following your twitter
    # as well as sleeping after each cycle
    #The 'i' loop is responsible for looping 'j' and DM'ing the correct candidates
    i = 0; while i < hours do
      j = 0; while j < 4 do # 4 cycles + 15 minute wait is approx 1hour
        puts 'Checking relationships...'

        #Calls from relationship method found in Follow class
        @users.each do |key, user|
          @new_obj = new_follow.check_if_following(user, @screen_name)
          @new_obj = JSON.parse(@new_obj.body)

          escape = 0
          while escape == 0
            if @new_obj != @rate_limit_error
              break
            end
            puts "API CALL LIMIT EXCEEDED"
            puts "waiting 1 minute"
            sleep(60)
            @new_obj = new_follow.check_if_following(user, @screen_name)
            @new_obj = JSON.parse(@new_obj.body)

          end

          #Checks if following
          if @new_obj['relationship']['target']['following']
            puts @new_obj['relationship']['target']['following']
            $redis.hmset user, 'follows', true

            check_if = @db_members.find(:username => user).first
            check_if['follows'] = true
              @db_members.update_one({:username => user}, check_if)
          end

        #Tweet at users even if they don't follow back
        if @new_obj['relationship']['target']['following'] == false
          spark = $redis.hmget user, 'tweeted'
          spark_bool = Integer(spark[0])
          if spark_bool < 1 #Since it is being interpreted weirdly as an array
            puts "THIS IS SPARK"
            puts user
            puts 'Tweeted: '
            puts spark
          end
          if spark_bool < 1
            spark_bool += 1
            tweet = PostTweet.new
            num = Random.new
            this_condition = $redis.hmget 'last_num', 'tweet_num'
            puts "This is my condition"
            puts this_condition
            new_num = num.rand(0..4)

            while new_num == this_condition
              new_num = num.rand(0..4)
              puts "///////////////////////////"
              puts "hello? #{new_num}"
              puts "///////////////////////////"
            end

            #new_tweet = "0x40#{user}" << @tweet_messages[new_num]
            at_user = "@#{user} "
            new_tweet = at_user.concat(@tweet_messages[new_num])
            puts new_tweet
            tweet.post_tweet new_tweet
            puts "///////////////////////////"
            puts "JUST TWEETED"
            puts "///////////////////////////"
            $redis.hmset 'last_num', 'tweet_num', new_num

            mongo_obj = {
                     :username => user,
                     :firstname => $redis.hmget(user, 'firstname'),
                     :lastname => $redis.hmget(user, 'lastname'),
                     :follows => false,
                     :did_dm => false,
                     :tweeted => 1
                    }
                    @db_members.update_one({:username => user}, mongo_obj)
            $redis.hmset user, 'tweeted', 1
          end
        end
      end
        puts "Completed cycle #{j+1} of 4 is"
        puts 'now sleeping...'
        sleep(5) #For seconds 900 = 15 minutes
                  #It is assumed you use 15 min. per cycle to accurately get an hour
        j +=  1

      end

        if @run_auto_dm #If user selected true for auto DM's this will run
          puts "DM'ing canidates"
          dms = Message.new
          dms.auto_dm @greeting, @users, @message
        end

      puts "#{i+1} of #{hours} hours remaining"
      ListScraper.update_scraper(@slug, @screen_name, @member_num, @users, @greeting) if @auto_update
      i += 1
    end
  end



  def self.update_scraper (slug, screen_name, member_num, users, greeting) #For use with class assigned updates

    puts "Updating Scraper..."
    test = List.new

    puts "Reading old files and objects"
    obj = test.getList_members slug, screen_name, member_num
    obj = JSON.parse(obj.body)

    count = obj['users'].count
    puts "Updating user list"
    i = 0; while i < count
             username = obj['users'][i]['screen_name']
             users[:"#{username}"] = username
             exists = $redis.hget username, 'firstname'
             if exists == nil
               firstname = obj['users'][i]['name'].split(' ').first
               lastname = obj['users'][i]['name'].split(' ').last
               $redis.mapped_hmset username, { firstname: firstname, lastname: lastname, follows: false,
                                               did_dm: false, tweeted: 0 }

              mongo_obj = {
                          :firstname => firstname,
                          :lastname => lastname,
                          :follows => false,
                          :did_dm => false,
                          :tweeted => 0
              }
              #puts mongo_obj

              check_if = @db_members.find(:username => username).firstname

              if check_if
                 $redis.mapped_hmset username , {
                                                 firstname: check_if[:firstname],
                                                 lastname:  check_if[:lastname],
                                                 follows:   check_if[:follows],
                                                 did_dm:    check_if[:did_dm],
                                                 tweeted:   check_if[:tweeted]
                                               }
              end

              @db_members.insert_one(mongo_obj) if check_if == nil


               puts "Following new users"
               new_follow = Follow.new
               @error_check = new_follow.follow(nil, username, false)
               @error_check = JSON.parse(@error_check.body)
               escape = 0

               while escape == 0
                 if @error_check != @rate_limit_error
                   break
                 end
                 puts "API CALL LIMIT EXCEEDED"
                 puts "waiting 1 minute"
                 sleep(60)
                 @error_check = new_follow.follow(nil, user, false)
                 @error_check = JSON.parse(@error_check.body)
               end
             end

             i += 1
           end

    @users = users
  end
end
