class AddUserAndChapterToReadingHistories < ActiveRecord::Migration[8.1]
  def change
    change_table :reading_histories, bulk: true do |t|
      t.references :user, null: true, foreign_key: true
      t.references :chapter, null: true, foreign_key: true
      t.string :mangadex_chapter_id
      t.string :chapter_label
    end
  end
end
