desc "Run a development server"
task :server do
  sh "ruby -run -e httpd . -p 4000"
end 
