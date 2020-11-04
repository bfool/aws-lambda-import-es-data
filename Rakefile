desc "Start rspec test"
task :test do
  sh "rspec"
end

desc "Deploy application"
task :deploy do
  puts "Deploy application to aws"
  system "sls deploy -s #{ARGV[1] || 'dev'}"
  exit
end

desc "Development console"
task :console do
  require 'pry'
  load "./app/main.rb"
  def reload!
    load "./app/main.rb"
    "OK"
  end
   Pry.start
end
