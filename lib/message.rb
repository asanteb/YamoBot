
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

  def init_auto_dm (users, greeting) #sets up automated messages

    @users = users #collects user array from and instances it

    json_obj = File.read('temp_dump/did_dm.json') #reads file create an instance hash
    @did_dm = JSON.parse(json_obj)

    if greeting
      json_obj1 = File.read('temp_dump/greetings.json')
      @greeting = JSON.parse(json_obj1)
    end
  end

  def auto_dm (message, follows_hash)

    new_message = Message.new
    i = 0
    custom_message = message

    @users.each do |key, user|
      if follows_hash[user] == true && @did_dm[user] == false
        if @greeting != nil
          custom_message = @greeting[user] <<  message
          puts "User:#{@greeting[user]} Key:#{@greeting[key]} #{key}"
        end
        new_message.direct_message nil, user, custom_message
        @did_dm[user] = true
      end
      i+=1
    end

    File.open('temp_dump/did_dm.json','w') do |f|
      f.write(@did_dm.to_json)
    end
  end


end

class Greeting

  def first_name_greeting (obj_location)
    puts "Setting up greetings"
    json_obj = File.read(obj_location) #'temp_dump/list_obj.json')
    obj = JSON.parse(json_obj)
    greeting = {}

    i = 0; while i < obj['users'].count
            name = obj['users'][i]['name'].split(' ').first #added first name
            puts "Adding #{name} to greetings"
            greeting[:"#{obj['users'][i]['screen_name']}"] = "Hi #{name}%2C"
            i += 1
           end
     puts greeting

    File.open('temp_dump/greetings.json', 'w') do |f|
      f.write(greeting.to_json)
    end
  end
end