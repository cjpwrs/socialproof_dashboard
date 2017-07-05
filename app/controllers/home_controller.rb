class HomeController < ApplicationController
  def index
  end

  def dashboard
    if current_user && current_user.stim_token.present? && current_user.stim_response && current_user.stim_response['account_id'].present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/account/growth/performance&token=#{current_user.stim_token}&account_id=#{current_user.stim_response['account_id']}")
      stim_response = url.read
    end
    byebug
    if stim_response.present?
      current_user.growth_performance = eval(stim_response)
    end

  end

  def welcome
  end

  def connect_account
    @stim_response = nil
  end
end