require 'i18n'

module UrlValidator
  files = Dir[File.join(File.dirname(__FILE__), 'locale/*.yml')]
  I18n.load_path.concat(files)
end
