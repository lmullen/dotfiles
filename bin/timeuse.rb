#!/usr/bin/env ruby

# Append a description of what I'm working on to my time use log

# Lincoln Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com
# MIT License <http://lmullen.mit-license.org/>

require "optparse"

# Default options
options = {:billable => FALSE, 
  :log_file => "/home/lmullen/Dropbox/Elements/time-use-journal.txt"}

# Get the options
ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] description"
  
  opts.separator ""
  opts.separator "Specific Options:"
  
  opts.on( "-b", "--billable", "Add a BILLABLE flag." ) do
    options[:billable] = TRUE 
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

# Write to the log_file
open(options[:log_file], "a") do |file| 
  if options[:billable]
    file.puts log_time + " BILLABLE " + log_description
  else 
    file.puts log_time + " " + log_description
  end
end
