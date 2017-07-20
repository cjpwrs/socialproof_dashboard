class Users::RegistrationsController < Devise::RegistrationsController
  include ActionView::Helpers::NumberHelper

  def new
    @subscription = Subscription.new
    @stripe_list = (Stripe::Plan.all).sort_by { |plan| plan[:amount] }
    @coupon = Stripe::Coupon.retrieve(ENV['COUPON_ID'])
    discount = @coupon[:percent_off].to_f/100
    @plans = @stripe_list.map{ |plan|
      price = plan[:amount].to_f/100
      price_with_discount = price * (1.00 - discount)

      [plan[:name] + ' - ' +  number_to_currency(price_with_discount, precision: 0) +
      ' for 30 days. After 30 days, ' + number_to_currency(price, precision: 0) + '/month', plan[:id]]
    }
    super
  end

  def create
    build_resource sign_up_params
    if resource.save
      add_to_getresponse_campaign(resource)
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

  def add_to_getresponse_campaign(user)
    url = 'https://api.getresponse.com/v3/contacts'
    body = {
      email: user.email,
      campaign: {
        campaignId: 'TDELr'
      },
      name: user.user_name,
      dayOfCycle: 0
    }.to_json

    headers = {
      content_type: 'application/json',
      x_auth_token: "api-key #{ENV['GET_RESPONSE_API_KEY']}"
    }

    RestClient.post(url, body, headers)
  rescue RestClient::Conflict,
         RestClient::BadRequest
    Rails.logger.info "Unable to add #{user.email} to GetResponse"
  end
end
