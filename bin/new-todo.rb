#!/usr/bin/env ruby

# Append a new todo to my inbox

# Lincoln Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com
# MIT License <http://lmullen.mit-license.org/>

require "optparse"

# Default options
options = {
  :todo_inbox => "/home/lmullen/notes/inbox.txt"
}

# Get the options
ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] description"
  
  opts.separator "Common Options:"
  
  opts.on( "-h", "--help", "Show this message.") do
    puts opts
    exit
  end
  
  begin
    opts.parse!
  rescue
    puts opts
    exit
  end
end

# Load the message
if ARGV[0].nil?
  puts "Please include a new todo item."
  exit
else 
  new_todo = ARGV[0]
end

# Write to the todo_inbox
open(options[:todo_inbox], "a") do |file| 
    file.puts  "+ " + new_todo
end
