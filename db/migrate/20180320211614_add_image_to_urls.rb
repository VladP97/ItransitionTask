class AddImageToUrls < ActiveRecord::Migration[5.1]
  def change
    add_column :urls, :image, :string
  end
end
