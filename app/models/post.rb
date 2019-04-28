class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }

  def pretty_created_at
  end
end
