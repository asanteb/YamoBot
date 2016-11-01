
class Message

  def direct_message(user_id, screen_name, text) #Choose between user id or screename // Text body might need
                                                                                        #special formating
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getMessage_URL

    address = URI("#{api_url}#{command_url}")
    address = URI("#{address}?text=#{text}&screen_name=#{screen_name}") if screen_name
    address = URI("#{address}?text=#{text}&user_id=#{user_id}") if user_id

    request = Net::HTTP::Post.new address.request_uri
    authReq = TLS.new
    authReq.connect_req address, request
  end


  def auto_dm (greeting, users, message)

    obj_e = File.read('lib/limit_error.json') #'temp_dump/list_obj.json')
    @rate_limit_error = JSON.parse(obj_e)

    new_message = Message.new
    i = 0
    @custom_message = message


    $redis = Redis.new #CHANGE IF DIFFERENT HERE

    client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'yamobot') #CHANGE IF DIFFERENT HERE
    db = client.database
    @db_members = db.collection('list_members')

    users.each do |key, user|

      did_dm = $redis.hget user, 'did_dm'
      follows = $redis.hget user, 'follows'
      firstname = $redis.hget user, 'firstname'
      if did_dm == 'false' and follows == 'true'
          puts "DM'ing #{user}"

          if greeting
            @custom_message = "Hi #{firstname}%2C " <<  message
          end
          @error_check = new_message.direct_message nil, user, @custom_message
          @error_check = JSON.parse(@error_check.body)
          escape = 0

          while escape == 0
            if @error_check != @rate_limit_error
              break
            end
            puts "API CALL LIMIT EXCEEDED"
            puts "waiting 1 minute"
            sleep(60)
            @error_check = new_message.direct_message nil, user, @custom_message
            @error_check = JSON.parse(@error_check.body)
          end
          $redis.hmset user, 'did_dm', true


          mongo_obj = {
                       :username => user,
                       :firstname => firstname,
                       :lastname => $redis.hget(user, 'lastname'),
                       :follows => follows,
                       :did_dm => true,
                       :tweeted => $redis.hget(user, 'tweeted')
                      }
          @db_members.update_one({:username => user}, mongo_obj)
      end
      i+=1
    end
  end



end
