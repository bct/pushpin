class UserController < ApplicationController
  def show
    redirect_to '/' unless @user
  end

  def create
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to user_path
    else
      render :action => "show"
    end
  end
end
