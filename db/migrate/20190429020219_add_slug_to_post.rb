class Post < ActiveRecord::Base
end

class AddSlugToPost < ActiveRecord::Migration[5.2]
  def up
    add_column :posts, :slug, :string
    Post.all.each do |post|
      post.slug = post.title.parameterize
      post.save!
    end
    change_column :posts, :slug, :string, null: false
    add_index :posts, :slug, unique: true
    change_column :posts, :title, :string, null: false, unique: true
  end

  def down
    remove_column :posts, :slug
  end
end
