class ChangeUrlInProduct < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :url
    add_column :products, :url, :integer, references: :urls
  end
end
