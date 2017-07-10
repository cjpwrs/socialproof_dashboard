class HomeController < ApplicationController
  def index
  end

  def dashboard
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      url = URI.parse("https://stimsocial.com/index.php?route=api/account/growth/performance&token=#{current_user.stim_token}&account_id=#{current_user.account_id}")
      stim_response = url.read
    end
    if stim_response.present?
      json = eval(stim_response)
      current_user.growth_performance = eval(stim_response) if json[:success]
    end

  end

  def welcome
  end

  def connect_account
    @stim_response = nil
  end
end
