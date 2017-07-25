#!/usr/bin/env ruby

require 'redd'
require 'hashwithindifferentaccess'
require './lib/tester'
require './lib/formatter'

# The bot's account
USERNAME  = 'wrongDarkSoulsSubBot'
# Hey, it's me!
AUTHOR    = 'xumiz'
# The version, duh.
VERSION   = '0.1.0'
# The target subreddit
SUBREDDIT = 'darksouls'

AUTH_DATA = Hash[
  YAML.load_file('./.auth').merge( {
      # Add mandatory user_agent
      user_agent: "Redd:wrongSarkSoulsSubBot:v#{VERSION} (by /u/#{AUTHOR})"
  } ).map{ |k, v| [k.to_sym, v] }
]

begin
  # Load authentication data (username, password, client_id, secret)
  session = Redd.it( AUTH_DATA )
  # We load the previous posts and start the stream
  session.subreddit( SUBREDDIT ).post_stream( limit:100 ) do |post|
    # puts "Test: #{post.url}"
    results = Tester::analyze( post )
    if results.any?
      # We don't want to create more than one comment per post
      already_done = false
      # So we read the comment of the post
      post.comments.each do |comment|
        # If we find a message from the bot we abort
        already_done = true and break if comment.author.name == USERNAME
      end
      # If we didn't write a comment before
      unless already_done
        # We format the comment
        comment = Formatter::as_comment( post, results )
        # We reply
        post.reply( comment )
        # Some debug
        puts post.url
      end
    end
  end
rescue Interrupt => i
  # Allow me to kill the script like a barbarian
rescue Exception => e
  puts "Exception"
  puts "-"*80
  puts e.inspect
  puts "-"*80
end
