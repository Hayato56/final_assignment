class AddDetailsToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :artist, :string
    add_column :posts, :genre, :string
    add_column :posts, :release_year, :integer
  end
end
