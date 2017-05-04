class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @subscription = Subscription.new
  end

  # def create
  #   @subscription = Subscription.new(params[:subscription])
  #   if @subscription.save_with_payment
  #     redirect_to @subscription, :notice => "Thank you for subscribing!"
  #   else
  #     render :new
  #   end
  # end

  def create
    # Amount in cents
    @amount = 500

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'usd'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end