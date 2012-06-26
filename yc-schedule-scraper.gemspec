Gem::Specification.new do |s|
  s.name = "yc-schedule-scraper"
  s.version = "0.1"
  s.date = "2012-06-26"
  s.authors = ["Al Wold"]
  s.email = "alwold@gmail.com"
  s.summary = "Scrapes schedule data for Yavapai College"
  s.files = ["lib/yc_schedule_scraper.rb", "lib/yc_class_info.rb", "AddTrustExternalCARoot.crt"]
  s.add_runtime_dependency "nokogiri"
end