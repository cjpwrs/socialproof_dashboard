class SubscriptionsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!

  def new
    @subscription = Subscription.new
    @stripe_list = (Stripe::Plan.all).sort_by { |plan| plan[:amount] }
    @plans =
      if current_user.subscriptions.count == 0
        @stripe_list.map{ |plan|
          price = plan[:amount].to_f/100
          coupon = Stripe::Coupon.retrieve(coupon_finder(plan))
          discount = coupon[:amount_off].to_f/100
          price_with_discount = price - discount

          [plan[:name] + ' - ' +  number_to_currency(price_with_discount, precision: 0) +
          ' for 30 days. After 30 days, ' + number_to_currency(price, precision: 0) + '/month', plan[:id]]
        }
      else
        @stripe_list.map{ |plan|
          [plan[:name] + ' - ' +
          number_to_currency((plan[:amount].to_f/100), precision: 0) + '/month', plan[:id]]}
      end
  end

  def coupon_finder(plan)
    if plan.name == 'BUSINESS'
      ENV['BUSINESS_COUPON']
    elsif plan.name == 'PRO+'
      ENV['PRO_COUPON']
    else
      ENV['STARTER_COUPON']
    end
  end

  def create
    plan_id = subscriptions_params['plan']
    plan = Stripe::Plan.retrieve(plan_id)

    customer = Stripe::Customer.create(
                  :description => "Customer for #{current_user.email}",
                  :source => subscriptions_params['stripe_card_token'],
                  :email => "#{current_user.email}"
                )
    coupon = current_user.subscriptions.count == 0 ? coupon_finder(plan) : nil
    stripe_subscription = customer.subscriptions.create(plan: plan.id, coupon: coupon)

    @subscription = current_user.subscriptions.new(stripe_subscription_id: stripe_subscription.id, status: stripe_subscription.status)
    if @subscription.save
      tracker do |t|
        t.google_adwords_conversion :conversion, { label: 'zAPvCNHs7XAQ0tvHmAM' }
        t.facebook_pixel :track, { type: 'Purchase', options: { value: 247.35, currency: 'USD' } }
      end
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
    subscription.update_attributes(status: strip_subscription.status)
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
