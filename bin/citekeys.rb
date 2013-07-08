#!/usr/bin/env ruby

# Grep list of citation keys

# Lincoln Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com
# MIT License <http://lmullen.mit-license.org/>

require "optparse"

# Default options
options = {:keys_file => "/home/lmullen/acad/research/bib/citekeys.txt"}

ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] search-string"

  # opts.separator ""
  # opts.separator "Specific Options:"

  opts.separator "Common Options:"

  opts.on( "-h", "--help",
   "Show this message." ) do
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

begin
  # The string to search for
  search_string = Regexp.new ARGV[0]
rescue TypeError => e
  puts "Please pass a string to search for."
  exit
end

File.open(options[:keys_file], "r") do |file|  
  puts file.grep(search_string)
end