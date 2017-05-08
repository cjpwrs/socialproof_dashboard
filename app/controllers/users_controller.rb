class UsersController < ApplicationController
  def validation_email
    @user = User.find_by :email => email_params
    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  private
  def email_params
    params[:user][:email]
  end
end
