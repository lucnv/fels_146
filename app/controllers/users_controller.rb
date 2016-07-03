class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]
  before_action :load_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:edit, :update]

  def index
    @users = User.order(:name).paginate page: params[:page], per_page: Settings.users_per_page
  end

  def show
    @activities = @user.activities.limit Settings.activities_on_profile
    @lessons = Lesson.by_user(@user).order(created_at: :desc)
      .paginate page: params[:page], per_page: Settings.lessons_per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "controllers.users.flash.success.signup"
      log_in @user
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controllers.users.flash.success.update_profile"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
