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
                                         did_dm: false, is_greeting: false }

          #@greeting[:"#{username}"] = "Hi #{name}%2C "
          i += 1
           end



    #Automatically follows all users in @user array
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

          if @new_obj['relationship']['target']['following']
            puts @new_obj['relationship']['target']['following']
            $redis.hmset user, 'follows', true
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
                                               did_dm: false, is_greeting: false }
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