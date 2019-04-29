# Enable additional languages
I18n.available_locales = [:en, :fr, :it, :es].sort

# Load JSON as well as .rb and .yml
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{json}')]

# Define a custom I18n backend that will write new translations received at
# runtime via store_translations to a standard translation file for later
# loading
class CrowdinBackend < I18n::Backend::Simple
  def store_translations(locale, data, options = I18n::EMPTY_HASH)
    super(locale, data, options)
    write_translations(locale, data) if initialized?
  end

  private

  def write_translations(locale, new_data)
    new_data = new_data.deep_stringify_keys
    existing_data = locale_data(locale)
    existing_data[locale.to_s].deep_merge!(new_data)
    File.write(locale_file(locale), JSON.pretty_generate(existing_data))
  end

  def locale_data(locale)
    JSON.parse(File.read(locale_file(locale)))
  rescue StandardError
    { locale.to_s => {}}
  end

  def locale_file(locale)
    Rails.root.join("config/locales/crowdin.#{locale}.json")
  end
end
I18n.backend = CrowdinBackend.new

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
