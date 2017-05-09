class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @subscription = Subscription.new
    @stripe_list = Stripe::Plan.all
    @plans = @stripe_list[:data].map{ |plan| [plan[:name] + ' - ' +  (plan[:amount].to_f/100).to_s + '/month', plan[:id]]}
    super
  end

  def create
    plan_id = subscriptions_params['plan']
    plan = Stripe::Plan.retrieve(plan_id)

    customer = Stripe::Customer.create(
                  :description => "Customer for #{current_user.email}",
                  :source => subscriptions_params['stripe_card_token'],
                  :email => "#{current_user.email}"
                )
    coupon = (plan.name == ENV['PLAN_TO_DISCOUNT']) ? ENV['COUPON_ID'] : nil
    stripe_subscription = customer.subscriptions.create(plan: plan.id, coupon: coupon)

    @subscription = current_user.subscriptions.new(stripe_subscription_id: stripe_subscription.id)
    if @subscription.save
      redirect_to @subscription
    else
      render :new_subscription
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end

  def show
    @subscription = get_subscription
    @strip_subscription_json = Stripe::Subscription.retrieve @subscription.stripe_subscription_id
    @card = Stripe::Customer.retrieve(@strip_subscription_json.customer).sources.data
  end

  private
  def subscriptions_params
    params.require(:subscription).permit(:plan, :stripe_card_token)
  end

  def subscription_id
    params['id']
  end

  def get_subscription
    Subscription.find subscription_id
  end
end
