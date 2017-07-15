class HomeController < ApplicationController
  def index
  end

  def dashboard
    if current_user && current_user.account_id.present? && !current_user.stim_token.present?
      current_user.refresh_stim_token
    end
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      stim_response = get_growth_data
      current_user.growth_performance = evaluate_response(stim_response)
    end
  end

  def get_growth_data
    url = URI.parse("https://stimsocial.com/index.php?route=api/account/growth/performance&token=#{current_user.stim_token}&account_id=#{current_user.account_id}")
    stim_response = url.read
    stim_response
  end

  def evaluate_response(stim_response)
    json = eval(stim_response)
    if !json[:success]
      current_user.refresh_stim_token
      stim_response = get_growth_data
      json = eval(stim_response)
    end
    eval(stim_response) if json[:success]
  end

  def welcome
  end

  def connect_account
    @stim_response = nil
  end
end
