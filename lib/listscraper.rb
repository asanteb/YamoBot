class ListScraper

  def configure_list (your_screen_name, slug, member_num, hours, run_auto_dm, message, greeting, auto_update)

    #initiallizes most local variables into instanced class variables
    @users = {}
    @follows_hash = {}
    @did_dm = {}
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
          @users[:"#{username}"] = username
          puts "Setting up for: #{obj['users'][i]['screen_name']}"
          @follows_hash[:"#{username}"] = false
          @did_dm[:"#{username}"] = false
          if @greeting
            name = obj['users'][i]['name'].split(' ').first
            @greeting[:"#{username}"] = "Hi #{name}%2C "
          end
          i += 1
           end

    #Sends @did_dm to json object for file storage
    File.open('temp_dump/did_dm.json','w') do |f|
      f.write(@did_dm.to_json)
    end
    #Sends main object 'obj' to json object for file storage
    File.open('temp_dump/list_obj.json','w') do |f|
      f.write(obj.to_json)
    end

    #If user wants a greeting to be added to the message
    #this will call an in class self function 'setup_greeting'
    File.open('temp_dump/greetings.json', 'w') do |f|
      f.write(@greeting.to_json)
    end

    #Automatically follows all users in @user array
    new_follow = Follow.new
    @users.each do |key, user|
      puts "Following #{user}"
      new_follow.follow(nil, user, false)
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
            @follows_hash[user] = true
          end

          #writes new changes in file for later recollection
          File.open('temp_dump/follows_obj.json','w') do |f|
            f.write(@follows_hash.to_json)
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
          dms.init_auto_dm @users, @greeting
          dms.auto_dm @message, @follows_hash
        end

      puts "#{i+1} of #{hours} hours remaining"
      ListScraper.update_scraper(@slug, @screen_name, @member_num, @users, @greeting) if @auto_update
      i += 1
    end
  end

  def self.setup_greeting #self called function specifically used twice for in class calling
    new_greeting = Greeting.new #creates object from 'Greeting' class found in 'message.rb'
    @send_greeting = new_greeting.first_name_greeting 'temp_dump/list_obj.json' #returns location of object
  end

  def update_scraper #updates scraper without re-configuring the list again

    puts "Updating Scraper..."
    test = List.new

    puts "Reading old files and objects"
    obj = test.getList_members @slug, @screen_name, @member_num
    obj = JSON.parse(obj.body)

    obj1 = File.read('temp_dump/did_dm.json') #'temp_dump/list_obj.json')
    obj1 = JSON.parse(obj1)

    obj2 = File.read('temp_dump/follows_obj.json') #'temp_dump/list_obj.json')
    obj2 = JSON.parse(obj2)

    if greeting
      obj3 = File.read('temp_dump/greetings.json')
      obj3 = JSON.parse(obj3)
    end


    count = obj['users'].count

    puts "Updating user list"
    i = 0; while i < count
           @users[:"#{obj['users'][i]['screen_name']}"] = obj['users'][i]['screen_name']
           i += 1
           end

    puts "Following new users"
    new_follow = Follow.new

    #This loop loops each user looping for new users that are not in the old hash
    #Changes are then placed in the created object for writing later
    j = 0
    @users.each do |user, value|
      if obj1[value] == nil
        obj1[:"#{value}"] = false
        puts "Added #{value} to did_dm"
      end
      if obj2[user] == nil
        obj2[:"#{value}"] = false
        puts "Added #{value} to follows_obj"
        puts "Following #{value}"
        new_follow.follow(nil, value, false)
      end
      if @greeting
        if obj3[value] == nil
          name = obj['users'][j]['name'].split(' ').first
          obj3[:"#{value}"] = "Hi #{name}%2C "
        end
      end
      j+=1
    end


    #writes the three objects to files
    puts "Writing new files..."
    File.open('temp_dump/list_obj.json','w') do |f|
      f.write(obj.to_json)
    end
    File.open('temp_dump/did_dm.json','w') do |f|
      f.write(obj1.to_json)
    end
    File.open('temp_dump/follows_obj.json','w') do |f|
      f.write(obj2.to_json)
    end

    #@greeting = ListScraper.setup_greeting if @greeting #updates greeting if there is any


  end

  def self.update_scraper (slug, screen_name, member_num, users, greeting) #For use with class assigned updates

    puts "Updating Scraper..."
    test = List.new

    puts "Reading old files and objects"
    obj = test.getList_members slug, screen_name, member_num
    obj = JSON.parse(obj.body)

    obj1 = File.read('temp_dump/did_dm.json') #'temp_dump/list_obj.json')
    obj1 = JSON.parse(obj1)

    obj2 = File.read('temp_dump/follows_obj.json') #'temp_dump/list_obj.json')
    obj2 = JSON.parse(obj2)

    temp = User.new

    if greeting
      obj3 = File.read('temp_dump/greetings.json')
      obj3 = JSON.parse(obj3)


    end

    count = obj['users'].count

    puts "Updating user list"
    i = 0; while i < count
             users[:"#{obj['users'][i]['screen_name']}"] = obj['users'][i]['screen_name']
             i += 1
           end

    puts "Following new users"
    new_follow = Follow.new

    #This loop loops each user looping for new users that are not in the old hash
    #Changes are then placed in the created object for writing later
    j = 0
    users.each do |user, value|
      if obj1[value] == nil
        obj1[:"#{value}"] = false
        puts "Added #{value} to did_dm"
      end
      if obj2[value] == nil
        obj2[:"#{value}"] = false
        puts "Added #{value} to follows_obj"
        puts "Following #{value}"
        new_follow.follow(nil, value, false)
      end

      if greeting
        if obj3[value] == nil
          user_info = temp.get_object nil, value
          user_info = JSON.parse(user_info.body)
          name = user_info['name'].split(' ').first
          obj3[:"#{value}"] = "Hi #{name}%2C "
        end
      end
    j+=1
    end



    #writes the three objects to files
    puts "Writing new files..."
    File.open('temp_dump/list_obj.json','w') do |f|
      f.write(obj.to_json)
    end
    File.open('temp_dump/did_dm.json','w') do |f|
      f.write(obj1.to_json)
    end
    File.open('temp_dump/follows_obj.json','w') do |f|
      f.write(obj2.to_json)
    end

    if greeting
      File.open('temp_dump/greetings.json','w') do |f|
        f.write(obj3.to_json)
      end
    end

    # Call at the very end
    #@greeting = ListScraper.setup_greeting if greeting #updates greeting if there is any

  end

end