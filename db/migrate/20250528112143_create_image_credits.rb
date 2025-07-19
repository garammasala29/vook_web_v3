class CreateImageCredits < ActiveRecord::Migration[8.0]
  def change
    create_table :image_credits do |t|
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }
      t.references :shop, null: false, foreign_key: true
      t.string :source_url

      t.timestamps
    end
  end
end
