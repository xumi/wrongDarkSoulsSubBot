require 'yaml'

class Tester

  def self.files
    return @files if @files
    # Load references
    @files = {
      DarkSouls1: YAML.load_file('./data/darksouls1.yml'),
      DarkSouls2: YAML.load_file('./data/darksouls2.yml'),
      DarkSouls3: YAML.load_file('./data/darksouls3.yml')
    }
  end

  def self.chosen_undead
    {
      DarkSouls1: self.files[:DarkSouls1]
    }
  end

  def self.invaders
    {
      DarkSouls2: self.files[:DarkSouls2],
      DarkSouls3: self.files[:DarkSouls3]
    }
  end

  def self.analyze ( post )
    # Does it have DS2 and/or DS3 mentions in its title?
    irrelevant_mentions = self.test_for_irrelevant_mentions( post )
    # Does it have DS1 mentions in its title OR content?
    relevant_mentions = self.test_for_relevant_mentions( post )
    # If it does but also have mentions to DS1 then we return nothing
    return [] if irrelevant_mentions.any? && relevant_mentions.any?
    # We return the DS2/3 mentions
    irrelevant_mentions
  end


  def self.test_for_irrelevant_mentions( post )
    results = {}
    self.invaders.each do |file, content|
      game = content['game']
      subreddit = content['subreddit']
      content['references'].each do |type, clues|
        next unless clues
        clues.each do |reference|
          reference.each_pair do |reference_name, reference_substring|
            reference_substring.each do |substring|
              # ['title','selftext'].each do |attribute|
              ['title','selftext'].each do |attribute|
                text = post.send( attribute )
                regexp = Regexp.new(/(^|\W)(#{substring})($|\W)/i)
                result = text.scan(regexp)
                if result and result[0]
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

  def self.test_for_relevant_mentions( post )
    results = {}
    self.chosen_undead.each do |file, content|
      game = content['game']
      subreddit = content['subreddit']
      content['references'].each do |type, clues|
        next unless clues
        clues.each do |reference|
          reference.each_pair do |reference_name, reference_substring|
            reference_substring.each do |substring|
              ['title','selftext'].each do |attribute|
                text = post.send( attribute )
                regexp = Regexp.new(/(^|\W)(#{substring})($|\W)/i)
                result = text.scan(regexp)
                if result and result[0]
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
