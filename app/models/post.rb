class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  validates :slug, presence: true, uniqueness: true
  before_validation :create_slug
  after_save :update_i18n

  def to_param
    slug
  end

  def create_slug
    self.slug = self.title.parameterize
  end

  def translated(attribute)
    return self[attribute] if I18n.locale == I18n.default_locale

    I18n.backend.load_translations_from_crowdin(I18n.locale, 'posts')
    I18n.t(attribute.to_s, scope: slug.to_s, default: self[attribute])
  end

  def update_i18n
    I18n.backend.update_source_in_crowdin(
      'posts',
      {
        slug => {
          title: title,
          text: text
        }
      }
    )
  end
end
