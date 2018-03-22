class AddNameToUrls < ActiveRecord::Migration[5.1]
  def change
    add_column :urls, :name, :string
  end
end
