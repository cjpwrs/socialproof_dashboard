class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:validation_email]

  def add_instagram_account
    account = user_params[:instagram_account]
    password = user_params[:instagram_password]
    if current_user.stim_token.present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/instagram/insert&token=#{current_user.stim_token}&username=#{account}&password=#{password}")
      stim_response = url.read
      return unless stim_response.present?
      @stim_response = eval(stim_response)
      if @stim_response[:success].present? && @stim_response[:success]
        current_user.stim_response = @stim_response
        current_user.save
        return redirect_to new_subscription_path
      elsif @stim_response[:success] == false && @stim_response[:errors].present?
        return render 'home/connect_account'
      end
    end
  end

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

  def user_params
    params[:user]
  end
end
