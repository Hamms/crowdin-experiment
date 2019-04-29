require 'rest-client'
require 'net/http'

# Enable additional languages
I18n.available_locales = [:en, :fr, :it, :es].sort

# Load JSON as well as .rb and .yml
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{json}')]

CROWDIN_LOCALE_MAPPING = {
  es: :'es-ES'
}

# Define a custom I18n backend that can sync changes to source strings to and
# download new translations from crowdin.
class CrowdinBackend < I18n::Backend::Simple
  def update_source_in_crowdin(file, new_data)
    write_translations(I18n.default_locale, file, new_data)
    RestClient.post(
      "https://api.crowdin.com/api/project/cdo-temp/update-file?key=#{CROWDIN_API_KEY}",
      {
        files: {
          "#{file}.json" => File.new(locale_file(I18n.default_locale, file), 'rb')
        }
      }
    )
  end

  def load_translations_from_crowdin(locale, file)
    Rails.cache.fetch("i18n/crowdin_translations/#{locale}/#{file}", expires_in: 1.hour) do
      crowdin_locale = CROWDIN_LOCALE_MAPPING.fetch(locale, locale)
      response = RestClient.get("https://api.crowdin.com/api/project/cdo-temp/export-file?key=#{CROWDIN_API_KEY}&file=#{file}.json&language=#{crowdin_locale}")
      data = JSON.parse(response)["en"]
      write_translations(locale, file, data)
    end
  end

  private

  def write_translations(locale, file, new_data)
    existing_data = locale_data(locale, file)
    existing_data[locale.to_s].deep_merge!(new_data.deep_stringify_keys)
    File.write(locale_file(locale, file), JSON.pretty_generate(existing_data))
    store_translations(locale, new_data)
  end

  def locale_data(locale, file)
    JSON.parse(File.read(locale_file(locale, file)))
  rescue StandardError
    { locale.to_s => {}}
  end

  def locale_file(locale, file)
    Rails.root.join("config/locales/#{file}.#{locale}.json")
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
