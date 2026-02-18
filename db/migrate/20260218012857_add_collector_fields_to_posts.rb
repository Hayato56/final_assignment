class AddCollectorFieldsToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :obi, :boolean
    add_column :posts, :cleaning_history, :text
  end
end
