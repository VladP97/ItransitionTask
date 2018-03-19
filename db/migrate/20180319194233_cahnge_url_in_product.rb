class CahngeUrlInProduct < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :url
  end
end
