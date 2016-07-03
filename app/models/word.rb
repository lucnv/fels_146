class Word < ActiveRecord::Base
  QUERRY_WORD_TRUE_LEARNT = "id in (SELECT DISTINCT ls.word_id FROM lesson_words ls
    INNER JOIN lessons l ON l.id = ls.lesson_id
    INNER JOIN word_answers wa ON ls.word_id = wa.word_id AND ls.word_answer_id = wa.id
    WHERE wa.is_correct = 't' AND l.user_id = :user_id AND l.is_completed = 't')"

  QUERRY_WORD_WRONG_LEARNT = "id in (SELECT DISTINCT ls.word_id FROM
    lesson_words ls JOIN lessons l ON ls.lesson_id = l.id
    WHERE l.user_id = :user_id AND l.is_completed = 't'
    EXCEPT
    SELECT DISTINCT ls.word_id FROM lesson_words ls
    INNER JOIN lessons l ON l.id = ls.lesson_id
    INNER JOIN word_answers wa ON ls.word_id = wa.word_id AND ls.word_answer_id = wa.id
    WHERE wa.is_correct = 't' AND l.user_id = :user_id AND l.is_completed = 't')"

  QUERRY_WORD_LEARNT = "id in (SELECT DISTINCT ls.word_id FROM lesson_words ls
    INNER JOIN lessons l ON ls.lesson_id = l.id
    WHERE l.user_id = :user_id AND l.is_completed = 't')"

  QUERRY_WORD_NOT_YET = "id not in (SELECT DISTINCT ls.word_id FROM
    lesson_words ls JOIN lessons l ON ls.lesson_id = l.id
    WHERE l.user_id = :user_id AND l.is_completed = 't')"

  has_many :word_answers, dependent: :destroy
  has_many :lesson_words, dependent: :destroy
  belongs_to :category

  scope :random, -> {order "RANDOM()"}
  scope :in_category, -> category_id do
    where category_id: category_id if category_id.present?
  end
  scope :all_words, -> user_id {}
  scope :not_yet, -> user_id {where QUERRY_WORD_NOT_YET, user_id: user_id}
  scope :learnt, ->user_id {where QUERRY_WORD_LEARNT, user_id: user_id}
  scope :true_learnt, ->user_id {where QUERRY_WORD_TRUE_LEARNT, user_id: user_id}
  scope :wrong_learnt, ->user_id {where QUERRY_WORD_WRONG_LEARNT, user_id: user_id}


  validates :name, presence: true, length: {maximum: 50}
  validate :check_answers

  accepts_nested_attributes_for :word_answers, allow_destroy: true,
    reject_if: proc {|attributes| attributes[:content].blank?}

  def correct_answer
    self.word_answers.correct.first
  end

  private
  def check_answers
    answers = self.word_answers.to_a.reject {|answer| answer.marked_for_destruction?}
    if answers.count < Settings.minimum_answers ||
      answers.count > Settings.maximum_answers
      self.errors.add :word_answers, I18n.t("models.word.errors.number_answers")
    end
    if answers.combination(2).any? {|a1, a2| a1.content == a2.content}
      self.errors.add :word_answers, I18n.t("models.word.errors.same_answers")
    end
    if answers.count {|answer| answer.is_correct?} != 1
      self.errors.add :word_answers, I18n.t("models.word.errors.correct_answers")
    end
  end
end
