class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :url
      t.decimal :min_price, :precision => 6, :scale => 2
      t.decimal :max_price, :precision => 6, :scale => 2

      t.timestamps
    end
  end
end
