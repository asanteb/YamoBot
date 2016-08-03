require 'redis'

redis = Redis.new




poo = redis.hgetall 'test'
poo1 = redis.hget 'test', 'hello'
err = redis.hgetall 'heyhey'

puts poo
puts poo1
puts err

if err == nil
  puts 'yes sir'
end