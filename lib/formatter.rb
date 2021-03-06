require 'uri'

class Formatter

  def self.as_comment ( post, results )
    # Get the list of games mentioned
    names = results.map{|result| result[:game]}.uniq
    # Get the list of target subreddits
    targets = results.map{|result| result[:target]}.uniq
    # Create the report link
    report_link = "https://www.reddit.com/message/compose/?to=wrongDarkSoulsSubBot&subject=False-Positive&message="+URI.escape(post.url)

    # Create text
    text = "It looks like you are talking about **#{names.join('** and **')}**. This subreddit is dedicated to **Dark Souls 1** only.\n\n"
    text += "You should invade #{targets.join(' and ')} instead!\n\n"
    text += "Don't give up skeleton!\n\n"
    text += "---\n"
    # Add some details about how we deduced that
    results.each do |result|
      text += "^^You ^^mentioned **^^#{result[:hint].split.join(' ^^')}** ^^and ^^I ^^assumed **^^#{result[:reference].split.join(' ^^')}** ^^from **^^#{result[:game].split.join(' ^^')}**^^.\n\n"
    end
    text += "---\n"
    text += "^^I ^^am ^^a ^^bot"
    text += " ^^| "
    text += "[^^Report ^^error ^^using ^^the ^^Orange ^^Soapstone]("+report_link+")"
    text
  end

end
