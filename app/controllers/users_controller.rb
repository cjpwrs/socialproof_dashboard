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
        current_user.account_id = @stim_response[:account_id]
        current_user.user_name = account
        current_user.stim_account = 'ridingjay' unless current_user.stim_account.present?
        current_user.save
        return redirect_to new_subscription_path
      elsif @stim_response[:success] == false && @stim_response[:errors].present?
        current_user.stim_response = @stim_response
        current_user.user_name = account
        current_user.stim_account = 'ridingjay' unless current_user.stim_account.present?
        current_user.save
        errors = @stim_response[:errors]
        if errors[:needs_verification].present?
          session[:instagram_account] = account
          session[:instagram_code] = password
          @stim_response = nil
          return render 'home/verify_account'
        else
          return render 'home/connect_account'
        end
      end
    end
  end

  def verify_instagram_account
    current_user.refresh_stim_token
    if current_user.stim_token.present?
      account =  session[:instagram_account]
      password =  session[:instagram_code]

      url = URI.parse("https://stimsocial.com/index.php?route=api/instagram/insert&token=#{current_user.stim_token}&username=#{account}&password=#{password}")
      stim_response = url.read
      return unless stim_response.present?
      @stim_response = eval(stim_response)
      if @stim_response[:success].present? && @stim_response[:success]
        current_user.stim_response = @stim_response
        current_user.account_id = @stim_response[:account_id]
        current_user.user_name = account
        current_user.stim_account = 'ridingjay' unless current_user.stim_account.present?
        current_user.save
        return redirect_to new_subscription_path
      elsif @stim_response[:success] == false && @stim_response[:errors].present?
        current_user.stim_response = @stim_response
        current_user.save
        errors = @stim_response[:errors]
        if errors[:exists].present?
          return redirect_to new_subscription_path
        else
          return render 'home/verify_account'
        end
      end
    end
  end

  def validation_email
    @user = User.find_by :email => email_params
    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  def get_account_info
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/account/info&token=#{current_user.stim_token}&account_id=#{current_user.account_id}")
      stim_response = url.read
    end
    stim_response
  end

  def account_info
    subscriptions = current_user.subscriptions.order(created_at: :desc)
    if subscriptions.length > 0
      subscription = subscriptions.first
      stripe_subscription = Stripe::Subscription.retrieve subscription.stripe_subscription_id
    else
      subscription = nil
      stripe_subscription = nil
    end

    stim_response = get_account_info
    if stim_response.present?
      json = eval(stim_response)
      if !json[:success]
        current_user.refresh_stim_token
        stim_response = get_account_info
        json = eval(stim_response)
      end

      return render json: {
        response: {
          stim_response: stim_response,
          subscription: subscription,
          stripe_subscription: stripe_subscription
        }
      }.to_json(), status: 200
    end
  end

  def target_performance
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/account/target/performance&token=#{current_user.stim_token}&account_id=#{current_user.account_id}")
      stim_response = url.read
    end
    if stim_response.present?
      return render json: {
        response: stim_response
      }.to_json(), status: 200
    end
  end

  def top_engagers
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/account/engager/top&token=#{current_user.stim_token}&account_id=#{current_user.account_id}")
      stim_response = url.read
    end
    if stim_response.present?
      return render json: {
        response: stim_response
      }.to_json(), status: 200
    end
  end

  def target_accounts
    if current_user.present?
      return render json: {
        response: current_user.target_accounts
      }.to_json(), status: 200
    end
  end

  def add_target_account
    instagram_handle = params[:new_target_account]
    similar_account = current_user.target_accounts.new(instagram_handle: instagram_handle)
    similar_account.save!
    @current_user = current_user.reload
    return render json: {
      response: current_user.target_accounts
    }.to_json(), status: 200
  end

  def delete_target_account
    target_account = params[:target_account_id]
    TargetAccount.find(target_account).destroy
    return render json: {
      response: current_user.target_accounts
    }.to_json(), status: 200
  end

  private
  def similar_account_id
    params[:id]
  end

  def email_params
    params[:user][:email]
  end

  def user_params
    params[:user]
  end
end
