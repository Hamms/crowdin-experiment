class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  validates :slug, uniqueness: true
  before_validation :create_slug
  after_save :update_i18n

  def to_param
    slug
  end

  def create_slug
    self.slug = self.title.parameterize
  end

  def translated(attribute)
    I18n.t(attribute.to_s, scope: slug.to_s, default: self[attribute])
  end

  def update_i18n
    I18n.backend.store_translations(I18n.default_locale,
      {
        slug => {
          title: title,
          text: text
        }
      }
    )
  end
end
