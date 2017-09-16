require "i18n"

# :nodoc:
module UriFormatValidator
  files = Dir[File.join(File.dirname(__FILE__), "locale/*.yml")]
  I18n.load_path.concat(files)
end
