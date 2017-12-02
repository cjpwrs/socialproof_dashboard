class UsersController < ApplicationController
  require 'authorizenet'

  include AuthorizeNet::API

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
        current_user.stim_account = 'jay' unless current_user.stim_account.present?
        current_user.save
        return redirect_to new_subscription_path
      elsif @stim_response[:success] == false && @stim_response[:errors].present?
        current_user.stim_response = @stim_response
        current_user.user_name = account
        current_user.stim_account = 'jay' unless current_user.stim_account.present?
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
        current_user.stim_account = 'jay' unless current_user.stim_account.present?
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
    if current_user.is_subscripted?
      subscription = current_user.lastest_subscription
      if subscription.authorizenet_subscription_id.present?
        authorizenet_subscription = get_existing_subscription_from_authorize(subscription)
        authorizenet_subscription = {
          status: authorizenet_subscription.subscription.status,
          name: authorizenet_subscription.subscription.name
        }
      else
        subscription = nil
        authorizenet_subscription = nil
      end
    else
      subscription = nil
      authorizenet_subscription = nil
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
          authorizenet_subscription: authorizenet_subscription
        }
      }.to_json(), status: 200
    else
      return render json: {
        response: {
          stim_response: nil,
          subscription: subscription,
          authorizenet_subscription: authorizenet_subscription
        }
      }.to_json(), status: 200
    end
  end

  def get_existing_subscription_from_authorize(subscription)
    transaction = Transaction.new(ENV['AUTHORIZE_LOGIN_ID'], ENV['AUTHORIZE_TRANSACTION_KEY'], :gateway => :production)

    request = ARBGetSubscriptionRequest.new

    request.subscriptionId = subscription.authorizenet_subscription_id

    response = transaction.arb_get_subscription_request(request)

    if response.messages.resultCode == MessageTypeEnum::Ok
      return response
    else
      raise "Failed to get subscription details."
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

  def max_following
    if current_user.present?
      return render json: {
        response: current_user.max_following
      }.to_json(), status: 200
    end
  end

  def set_max_following
    max_following = params[:max_following]
    current_user.max_following = max_following
    current_user.save!
    send_slack_notification(current_user, max_following)
    return render json: {
      response: current_user.max_following
    }.to_json(), status: 200
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

  def send_slack_notification(user, max_following)
    url = 'https://hooks.slack.com/services/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'
    body = {
      text: "<https://dashboard.socialproofco.com/admin/users/#{user.id}|#{user.email}> changed their max following to #{max_following}"
    }.to_json

    headers = {
      content_type: 'application/json'
    }

    RestClient.post(url, body, headers)
  end
end
