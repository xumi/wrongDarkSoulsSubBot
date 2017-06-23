require 'yaml'

class Tester

  def self.files
    return @files if @files
    # Load references
    @files = {
      DarkSouls2: YAML.load_file('./data/darksouls2.yml'),
      DarkSouls3: YAML.load_file('./data/darksouls3.yml')
    }
  end

  def self.analyze ( post )
    results = {}
    self.files.each do |file, content|
      game = content['game']
      subreddit = content['subreddit']
      content['references'].each do |type, clues|
        next unless clues
        clues.each do |reference|
          reference.each_pair do |reference_name, reference_substring|
            reference_substring.each do |substring|
              ['title','selftext'].each do |attribute|
                if post.send( attribute ).downcase.include?( substring.downcase )
                    # Only flag the longest hint
                    next if results[reference_name]
                    # Add the hint to the list of results
                    results[reference_name] = { game: game, source: attribute, reference: reference_name, hint:substring, target: subreddit }
                    break
                end
              end
            end
          end
        end
      end
    end
    # We don't need the references, just the results
    results.values
  end

end
