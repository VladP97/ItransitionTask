class AddUrlReferenceToProduct < ActiveRecord::Migration[5.1]
  def change
    add_reference :products, :url, foreign_key: true
  end
end
