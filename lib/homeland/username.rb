module Homeland
  class Username
    def self.sanitize(username)
      username.gsub(/[^\w.-]/, "_")
    end

    # https://stackoverflow.com/questions/24672834/how-do-i-remove-emoji-from-string
    def self.strip_emoji(text)
      text = text.force_encoding('utf-8').encode
      clean = ""

      # symbols & pics
      regex = /[\u{1f300}-\u{1f5ff}]/
      clean = text.gsub regex, ""

      # enclosed chars
      regex = /[\u{2500}-\u{2BEF}]/ # I changed this to exclude chinese char
      clean = clean.gsub regex, ""

      # emoticons
      regex = /[\u{1f600}-\u{1f64f}]/
      clean = clean.gsub regex, ""

      #dingbats
      regex = /[\u{2702}-\u{27b0}]/
      clean = clean.gsub regex, ""
    end
  end
end
