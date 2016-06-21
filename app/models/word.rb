class Word < ActiveRecord::Base
  has_many :word_answers, dependent: :destroy
  has_many :lesson_words, dependent: :destroy
  belongs_to :category
end
