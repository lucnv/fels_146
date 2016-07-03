class LessonsController < ApplicationController
  before_action :logged_in_user
  before_action :load_lesson, :authorize_user, only: [:edit, :update, :show]
  before_action :verify_completed_lesson, only: [:edit, :update]
  before_action :verify_uncompleted_lesson, only: :show

  def create
    @lesson = Lesson.new category_id: params[:category_id],
      user_id: current_user.id
    if @lesson.save
      flash[:success] = t "controllers.lessons.flash.success.create_lesson"
      current_user.store_action Activity.actions[:start_lesson], @lesson.id
      redirect_to edit_lesson_path @lesson
    else
      flash[:danger] = @lesson.errors.full_messages.last
      redirect_to categories_path
    end
  end

  def edit
  end

  def update
    completed_lesson_params = lesson_params
    completed_lesson_params[:is_completed] = true
    if @lesson.update_attributes completed_lesson_params
      flash[:success] = t "controllers.lessons.flash.success.finish"
      current_user.store_action Activity.actions[:finish_lesson], @lesson.id
      redirect_to lesson_path @lesson
    else
      flash[:danger] = t "controllers.lessons.flash.danger.finish"
      redirect_to edit_lesson_path @lesson
    end
  end

  def show
  end

  private
  def load_lesson
    @lesson = Lesson.find_by id: params[:id]
    unless @lesson
      flash[:danger] = t "controllers.lessons.flash.danger.invalid_lesson"
      redirect_to categories_path
    end
  end

  def authorize_user
    unless current_user.is_user? @lesson.user
      flash[:danger] = t "controllers.lessons.flash.danger.no_permission"
      redirect_to root_url
    end
  end

  def verify_completed_lesson
    if @lesson.is_completed?
      flash[:info] = t "controllers.lessons.flash.info.finished"
      redirect_to lesson_path @lesson
    end
  end

  def verify_uncompleted_lesson
    unless @lesson.is_completed?
      flash[:danger] = t "controllers.lessons.flash.danger.require_finish"
      redirect_to edit_lesson_path @lesson
    end
  end

  def lesson_params
    params.require(:lesson).permit lesson_words_attributes: [:id, :word_answer_id]
  end
end
