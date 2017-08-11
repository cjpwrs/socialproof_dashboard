class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
  end

  def dashboard
    @current_user = current_user
    @hours_since_creation = (DateTime.now - DateTime.parse((current_user.created_at).to_s)).to_i
    @active_stripe_subscription = nil
    if current_user.is_subscripted?
      subscription = current_user.lastest_subscription
      @active_stripe_subscription = Stripe::Subscription.retrieve subscription.stripe_subscription_id
    end

    if current_user && current_user.account_id.present? && !current_user.stim_token.present?
      current_user.refresh_stim_token
    end
    if current_user && current_user.stim_token.present? && current_user.account_id.present?
      stim_response = get_growth_data
      response = evaluate_response(stim_response)
      if response.present?
        growth_performance = evaluate_response(stim_response)[:data]
        if growth_performance.count > 31
          growth_performance = growth_performance.select { |day| day[:followers] != 0 }
        end
        current_user.growth_performance = (growth_performance).sort_by { |day| day[:date] }.reverse!
      end
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
    tracker do |t|
      t.google_adwords_conversion :conversion, {}
      t.facebook_pixel :track, { type: 'Lead', options: { value: 10.00, currency: 'USD' } }
    end
  end

  def connect_account
    @stim_response = nil
  end

  def verify_account
    @stim_response = nil
  end
end
