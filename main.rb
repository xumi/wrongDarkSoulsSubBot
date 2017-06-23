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
VERSION   = '0.0.1'
# The target subreddit
# SUBREDDIT = 'darksouls'
SUBREDDIT = 'bottest' # TEST

# Load authentication data (username, password, client_id, secret)
session = Redd.it( Hash[
  YAML.load_file('./.auth').merge( {
      # Add mandatory user_agent
      user_agent: "Redd:wrongSarkSoulsSubBot:v#{VERSION} (by /u/#{AUTHOR})"
  } ).map{ |k, v| [k.to_sym, v] }
] )

begin
  session.subreddit( SUBREDDIT ).post_stream( limit:100 ) do |post|
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
        # We reply
        post.reply( Formatter::as_comment( results ) )
        # Some debug
        puts "# replied to #{post.url}"
      end
    end
  end
rescue Interrupt => i
  # Allow me to kill the script like a barbarian
end
