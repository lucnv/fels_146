class CreateWordAnswers < ActiveRecord::Migration
  def change
    create_table :word_answers do |t|
      t.string :content
      t.boolean :is_correct
      t.references :word, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
