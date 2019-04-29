# Enable additional languages
I18n.available_locales = [:en, :fr, :it, :es].sort

# Default to English when translation not found
old_handler = I18n.exception_handler
I18n.exception_handler = lambda do |exception, locale, key, options|
  case exception
  when I18n::MissingTranslation
    I18n.backend.translate(:en, key, options || {})
  else
    old_handler.call(exception, locale, key, options)
  end
end
