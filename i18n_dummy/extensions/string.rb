class String
  def without_marker
    gsub ::I18nDummy::Settings.marker_regex, ''
  end

  def key_updated?
    match ::I18nDummy::Settings.marker_regex
  end

  def dequote
    s = strip
    if s.start_with?("'")
      # single quoted http://yaml.org/spec/current.html
      s = s.gsub("''","'")
    end
    s.gsub(/^("|')/,'').gsub(/("|')$/,'').gsub('\\','')
  end

  def quote
    "\"#{gsub('"','\"')}\""
  end

  def escape
    # escape double quotes
    gsub(/(?<!\\)(")/,'"')
  end
end
