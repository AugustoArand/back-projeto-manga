class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :manga, null: true, foreign_key: true
      t.string :mangadex_id
      t.string :title, null: false
      t.string :cover_url
      t.string :genre

      t.timestamps
    end

    add_index :favorites, [:user_id, :mangadex_id], unique: true
    add_index :favorites, [:user_id, :manga_id], unique: true
  end
end
