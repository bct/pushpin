class WallController < ApplicationController
  # GET /wall
  def show
    @user = find_user

    if @user
      @collections = @user.collections
    else
      @collections = []
    end

    respond_to do |format|
      format.html # index.rhtml
    end
  end
end
