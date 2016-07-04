class Lesson < ActiveRecord::Base
  has_many :lesson_words, dependent: :destroy
  belongs_to :category
  belongs_to :user

  delegate :name, to: :category

  before_create :assign_words

  scope :by_user, -> (user) {where user_id: user.id}

  validates :category, presence: true
  validate :check_words_category

  accepts_nested_attributes_for :lesson_words,
    reject_if: proc {|attributes| attributes[:word_answer_id].blank?}

  def count_correct_answers
    if self.is_completed?
      LessonWord.correct.in_lesson(self).count
    end
  end

  private
  def assign_words
    Word.in_category(self.category.id).random.limit(Settings.words_in_lesson)
      .each do |word|
      self.lesson_words.build word_id: word.id
    end
  end

  def check_words_category
    unless self.category && self.category.words.count >= Settings.words_in_lesson
      self.errors.add :category,
        I18n.t("models.lesson.errors.not_enough_words")
    end
  end
end
