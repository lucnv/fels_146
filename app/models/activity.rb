class Activity < ActiveRecord::Base
  belongs_to :user
  default_scope -> {order created_at: :desc}

  enum action: {follow: 1, unfollow: 2, start_lesson: 3, finish_lesson: 4}

  def target_object
    case self.action_type
    when Activity.actions[:follow]
      User.find_by id: self.target_id
    when Activity.actions[:unfollow]
      User.find_by id: self.target_id
    when Activity.actions[:start_lesson]
      Lesson.find_by id: self.target_id
    when Activity.actions[:finish_lesson]
      Lesson.find_by id: self.target_id
    end
  end
end
