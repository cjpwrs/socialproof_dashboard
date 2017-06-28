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
    stripe_subscription = customer.subscriptions.create(plan: plan.id, coupon: ENV['COUPON_ID'])

    @subscription = current_user.subscriptions.new(stripe_subscription_id: stripe_subscription.id, status: stripe_subscription.status)
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
    if @strip_subscription_json.status == 'canceled'
      redirect_to new_subscription_path
    else
      @card = Stripe::Customer.retrieve(@strip_subscription_json.customer).sources.data
    end
  end

  def cancel
    subscription = current_user.subscriptions.order(id: :asc).where(id: subscription_id).first
    strip_subscription = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    strip_subscription.delete(:at_period_end => false)
    subscription.update_attibutes(status: strip_subscription.status)
    redirect_to new_subscription_path
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
