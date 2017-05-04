class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @subscription = Subscription.new
    @stripe_list = Stripe::Plan.all
    @plans = @stripe_list[:data].map{ |plan| [plan[:name] + ' - ' +  (plan[:amount].to_f/100).to_s + '/month', plan[:id]]}
  end

  def create
    plan_id = subscriptions_params['plan']
    plan = Stripe::Plan.retrieve(plan_id)
    
    customer = Stripe::Customer.create(
                  :description => "Customer for #{current_user.email}",
                  :source => subscriptions_params['stripe_card_token'],
                  :email => "#{current_user.email}"
                )
    stripe_subscription = customer.subscriptions.create(:plan => plan.id)

    @subscription = current_user.subscriptions.new(stripe_subscription_id: stripe_subscription)
    if @subscription.save
      redirect_to root_path
    else
      render :new_subscription
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end

  private
  def subscriptions_params
    params.require(:subscription).permit(:plan, :stripe_card_token)
  end
end