#!/usr/bin/env ruby

# Append a description of what I'm working on to my time use log

# Lincoln Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com
# MIT License <http://lmullen.mit-license.org/>

require "optparse"

# Default options
options = {:billable => FALSE, :done => FALSE,
  :log_file => "/home/lmullen/todo/time-use.txt"}

# Get the options
ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] description"
  
  opts.separator ""
  opts.separator "Specific Options:"
  
  opts.on( "-b", "--billable", "Add a BILLABLE flag." ) do
    options[:billable] = TRUE 
  end 

  opts.on( "-d", "--done", "Add a DONE flag." ) do
    options[:done] = TRUE 
  end 

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
  puts "Please pass a description to log."
  exit
else 
  log_description = ARGV[0]
end

log_time = Time.now.strftime("%F-%H-%M-%S")

# Construct the entry
entry = log_time
entry += " BILLABLE" if options[:billable]
entry += " DONE" if options[:done]
entry += " " + log_description

# Write to the log_file
open(options[:log_file], "a") do |file| 
  file.puts entry
end
