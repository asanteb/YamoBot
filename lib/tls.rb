load "config/config-oauth.rb"

class TLS

  def connect_req(address, request)
    http = Net::HTTP.new address.host, address.port #Creates a http object. host and port are created from our API calls
    http.use_ssl = true       #Enables ssl in the http object(https) this is required for all twitter calls
    http.ssl_version = :SSLv3 #Sellects SSL & TLS version
    http.ssl_version = :TLSv1
    http.ca_file = File.join(File.expand_path('keys/cacert.pem')) #To get SSL working correctly you need to add CA.pems
                                                                  #keys to the http object
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER    #Since everything we need is added to http, we verify it

    authenticator = USER_OAUTH.new #New instance oauth-config class is called
    consumer_key = authenticator.getConsumerKey   #instance then uses the getter methods and verifications to create
    access_token = authenticator.getAccessToken   #new consumer_keys and access_tokens for this request/API-Call

    request.oauth! http, consumer_key, access_token #http object, tokens and keys are set to the oauth method
                                                    #the "!" modifies the method oauth itself. a new request is created
    http.start    #starts http configuration to what we wrote above

   @response = http.request request #http with request configurations requested through twitter(api.twitter.com)
                                    #The request always returns a response object. This can be parsed to JSON
                                    #And the data stored through various implementations such as tweet collections
                                    #lists, databases, searches etc...

  end
end