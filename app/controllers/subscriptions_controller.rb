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
    p params

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end