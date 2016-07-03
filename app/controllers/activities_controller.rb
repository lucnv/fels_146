class ActivitiesController < ApplicationController
  before_action :logged_in_user, :load_user
  def index
    @activities = @user.activities.paginate page: params[:page],
      per_page: Settings.activities_per_page
  end
end
