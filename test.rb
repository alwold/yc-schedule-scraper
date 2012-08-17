require './lib/yc_schedule_scraper.rb'

s = YcScheduleScraper.new
puts s.get_class_status('201230', '35016')

info = s.get_class_info('201230' ,'35016')
if info.nil?
  puts "no info"
else
  puts "Name: " << info.name 
  puts "Schedule: " << info.schedule
end

puts s.get_class_status('201230', 'stu150')
puts s.get_class_info('201230', 'stu150')