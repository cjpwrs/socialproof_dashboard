class Users::RegistrationsController < Devise::RegistrationsController
  include ActionView::Helpers::NumberHelper
  def new
    @subscription = Subscription.new
    @stripe_list = (Stripe::Plan.all).sort_by { |plan| plan[:amount] }
    puts @stripe_list.inspect
    list = @stripe_list
    puts list.inspect
    @coupon = Stripe::Coupon.retrieve(ENV['COUPON_ID'])
    puts @coupon.inspect
    discount = @coupon[:percent_off].to_f/100
    puts discount.inspect
    @plans = @stripe_list.map{ |plan|
      price = plan[:amount].to_f/100
      price_with_discount = price * (1.00 - discount)

      [plan[:name] + ' - ' +  number_to_currency(price_with_discount, precision: 0) +
      ' for 30 days. After 30 days, ' + number_to_currency(price, precision: 0) + '/month', plan[:id]]
    }
    puts @plans.inspect
    super
  end

  def create
    build_resource sign_up_params
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
      end
      respond_to do |format|
        format.json { render json: {success: true} }
        format.html { redirect_to dashboard_path }
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.html {
          flash[:alert] = resource.errors.full_messages.to_sentence
          redirect_to root_path
        }
        format.json { render json: {success: false} }
      end
    end
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end
end
