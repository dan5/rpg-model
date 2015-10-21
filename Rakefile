
task :api do
  sh %Q!wget --post-data='name=testman&foo=hello' http://localhost:3003/ -O - | cat!
end

task :s do
  sh 'bundle exec ruby app.rb -o 0.0.0.0 -p 3003'
end
