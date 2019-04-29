class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  after_save :update_i18n

  def translated(attribute)
    I18n.t(attribute.to_s, scope: id.to_s, default: self[attribute])
  end

  def update_i18n
    I18n.backend.store_translations(I18n.default_locale,
      {
        id => {
          title: title,
          text: text
        }
      }
    )
  end
end
