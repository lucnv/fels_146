class Word < ActiveRecord::Base
  QUERRY_WORD_TRUE_LEARNT = "id in (SELECT DISTINCT ls.word_id FROM lesson_words ls
    INNER JOIN lessons l ON l.id = ls.lesson_id
    INNER JOIN word_answers wa ON ls.word_id = wa.word_id AND ls.word_answer_id = wa.id
    WHERE wa.is_correct = 't')"

  QUERRY_WORD_WRONG_LEARNT = "id in (SELECT ls.word_id FROM
    lesson_words ls JOIN lessons l ON ls.lesson_id = l.id
    WHERE ls.word_id not in (SELECT DISTINCT ls.word_id FROM lesson_words ls
    INNER JOIN lessons l ON l.id = ls.lesson_id
    INNER JOIN word_answers wa ON ls.word_id = wa.word_id AND ls.word_answer_id = wa.id
    WHERE wa.is_correct = 't') and  l.user_id = ?)"

  QUERRY_WORD_LEARNT = "id in (SELECT ls.word_id FROM
    lesson_words ls JOIN lessons l ON ls.lesson_id = l.id
    WHERE l.user_id = ?)"
  QUERRY_WORD_NOT_YET = "id not in (SELECT ls.word_id FROM
    lesson_words ls JOIN lessons l ON ls.lesson_id = l.id
    WHERE l.user_id = ?)"

  has_many :word_answers, dependent: :destroy
  has_many :lesson_words, dependent: :destroy
  belongs_to :category

  validates :name, presence: true, length: {maximum: 50}
  validate :check_answers

  accepts_nested_attributes_for :word_answers, allow_destroy: true,
    reject_if: proc {|attributes| attributes[:content].blank?}

  scope :random, -> {order "RANDOM()"}
  scope :in_category, -> (category) {where category_id: category.id}
  scope :all_words, ->user_id{}
  scope :not_yet, ->user_id{where QUERRY_WORD_NOT_YET, user_id}
  scope :learnt, ->user_id{where QUERRY_WORD_LEARNT, user_id}
  scope :true_learnt, ->user_id{where QUERRY_WORD_TRUE_LEARNT, user_id}
  scope :wrong_learnt, ->user_id{where QUERRY_WORD_WRONG_LEARNT, user_id}
  scope :in_category, ->category_id do
    where category_id: category_id if category_id.present?
  end

  private
  def check_answers
    if self.word_answers.empty?
      self.errors.add :word, I18n.t("models.word.errors.required_answer")
    else
      count_correct_answers = 0
      self.word_answers.each do |answer|
        unless answer.marked_for_destruction?
          count_correct_answers += 1 if answer.is_correct?
        end
      end
    end
    if count_correct_answers != 1
      self.errors.add :word, I18n.t("models.word.errors.correct_answer")
    end
  end
end
