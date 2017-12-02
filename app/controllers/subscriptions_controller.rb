class SubscriptionsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!


  require 'rubygems'
  require 'yaml'
  require 'authorizenet'
  require 'securerandom'

  include AuthorizeNet::API



  def new
    @subscription = Subscription.new
    @plan_list = SubscriptionType.all
    @plans =
      if current_user.subscriptions.count == 0
        @plan_list.map{ |plan|
          [plan[:plan_name] + ' - ' +  number_to_currency(plan[:trial_amount], precision: 0) +
          ' for 30 days. After 30 days, ' + number_to_currency(plan[:monthly_amount], precision: 0) + '/month', plan[:id]]
        }
      else
        @plan_list.map{ |plan|
          [plan[:plan_name] + ' - ' +
          number_to_currency(plan[:monthly_amount], precision: 0) + '/month', plan[:id]]}
      end
  end

  def create
    plan_id = subscriptions_params['plan']
    plan = SubscriptionType.find(plan_id)
    card_number = subscriptions_params['card_number']
    card_cvc = subscriptions_params['card_cvc']
    card_expiry = subscriptions_params['card_expiry']
    email = subscriptions_params['email']
    name_on_card = subscriptions_params['name_on_card']

    transaction = Transaction.new(ENV['AUTHORIZE_LOGIN_ID'], ENV['AUTHORIZE_TRANSACTION_KEY'], :gateway => :production)
    p transaction

    request = ARBCreateSubscriptionRequest.new
    request.refId = DateTime.now.to_s[-8]
    request.subscription = ARBSubscriptionType.new
    request.subscription.name = plan.plan_name
    request.subscription.paymentSchedule = PaymentScheduleType.new
    request.subscription.paymentSchedule.interval = PaymentScheduleType::Interval.new("1","months")
    request.subscription.paymentSchedule.startDate = (DateTime.now).to_s[0...10]
    request.subscription.paymentSchedule.totalOccurrences ='9999'
    request.subscription.paymentSchedule.trialOccurrences ='1'

    request.subscription.amount = plan.monthly_amount
    request.subscription.trialAmount = plan.trial_amount
    request.subscription.payment = PaymentType.new
    request.subscription.payment.creditCard = CreditCardType.new(card_number, card_expiry, card_cvc)

    request.subscription.order = OrderType.new(current_user.id,'New Subscription')
    request.subscription.customer = CustomerType.new(CustomerTypeEnum::Individual, current_user.id, current_user.email)
    request.subscription.billTo = NameAndAddressType.new(name_on_card, name_on_card)

    response = transaction.create_subscription(request)

    if response != nil
      if response.messages.resultCode == MessageTypeEnum::Ok
        @new_subscription = current_user.subscriptions.new(authorizenet_subscription_id: response.subscriptionId, status: 'active')
        if @new_subscription.save
          User.update(
            current_user.id,
            :customer_profile_id => response.profile.customerProfileId,
            :customer_payment_profile_id => response.profile.customerPaymentProfileId
          )
          update_getresponse_campaign(current_user)
          tracker do |t|
            t.google_adwords_conversion :conversion, { label: 'zAPvCNHs7XAQ0tvHmAM' }
            t.facebook_pixel :track, { type: 'Purchase', options: { value: 247.35, currency: 'USD' } }
          end
          redirect_to @new_subscription
        else
          render :new_subscription
        end
      else
        @new_subscription_error = response.messages.messages[0].text
        new()
        puts @new_subscription_error
        # redirect_to new_subscription_path
        return render 'subscriptions/new'
      end
    end
    return response
  end

  def show
    @subscription = get_subscription
    if @subscription.authorizenet_subscription_id.present?
      @authorizenet_subscription = get_existing_subscription_from_authorize(@subscription)
    else
      redirect_to new_subscription_path
    end
  end

  def get_existing_subscription_from_authorize(subscription)
    transaction = Transaction.new(ENV['AUTHORIZE_LOGIN_ID'], ENV['AUTHORIZE_TRANSACTION_KEY'], :gateway => :production)

    request = ARBGetSubscriptionRequest.new

    request.subscriptionId = subscription.authorizenet_subscription_id

    response = transaction.arb_get_subscription_request(request)

    if response.messages.resultCode == MessageTypeEnum::Ok
      return response
    else
      raise "Failed to get subscription details."
    end
  end

  def upgrade_plan

  end

  def get_proration
    plan_param = params[:selected_plan]
    subscriptions = current_user.subscriptions.order(created_at: :desc)
    subscription = subscriptions.first
    stripe_list = Stripe::Plan.all
    selected_plan = stripe_list.find {|plan| plan["name"] == plan_param }
    stripe_subscription_json = Stripe::Subscription.retrieve subscription.stripe_subscription_id

    proration_date = Time.now.to_i

    # See what the next invoice would look like with a plan switch
    # and proration set:
    invoice = Stripe::Invoice.upcoming(
      :customer => stripe_subscription_json.customer,
      :subscription => subscription.stripe_subscription_id,
      :subscription_plan => selected_plan.id, # Switch to new plan
      :subscription_proration_date => proration_date)


    # Calculate the proration cost:
    current_prorations = invoice.lines.data.select { |ii| ii.period.start == proration_date }
    cost = 0
    current_prorations.each do |p|
      cost += p.amount
    end
    prorated_cost =  cost.to_f/100

    return render json: {
      response: {
        proration: prorated_cost,
        selected_plan: selected_plan,
        selected_plan_price: selected_plan[:amount].to_f/100
      }
    }.to_json(), status: 200
  end

  def get_upgrade_plan
    @subscription = Subscription.new
    @stripe_list = (Stripe::Plan.all).sort_by { |plan| plan[:amount] }
    subscriptions = current_user.subscriptions.order(created_at: :desc)
    @plans =
      if subscriptions.size == 0
        redirect_to :root
      else
        @subscription = subscriptions.first
        @strip_subscription_json = Stripe::Subscription.retrieve @subscription.stripe_subscription_id

        @stripe_list.reject!{ |plan| plan.name == @strip_subscription_json.plan.name }.map{ |plan|
          price = plan[:amount].to_f/100

          [plan[:name], plan[:id]]
        }
      end

      return render json: {
        response: {
          plans: @plans,
          current_subscription: @subscription
        }
      }.to_json(), status: 200
  end

  def upgrade
    plan_param = params[:selected_plan]
    subscriptions = current_user.subscriptions.order(created_at: :desc)
    subscription = subscriptions.first
    stripe_list = Stripe::Plan.all
    selected_plan = stripe_list.find {|plan| plan["name"] == plan_param }

    plan = Stripe::Plan.retrieve(selected_plan[:id])
    stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    stripe_subscription.plan = plan.id
    stripe_subscription.save

    send_slack_notification(current_user, plan_param)
    if stripe_subscription.status == 'active'
      render json: {"redirect":true,"redirect_url": subscription_path(:id=> subscription.id)}, status:200
    else
      render :upgrade_plan
    end
  end

  def cancel
    cancel_subscription
    redirect_to new_subscription_path
  end

  private
  def cancel_subscription
    subscription = current_user.subscriptions.order(id: :asc).where(id: subscription_id).first
    strip_subscription = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    strip_subscription.delete(:at_period_end => false)
    subscription.update_attributes(status: strip_subscription.status)
  end

  def subscriptions_params
    params.require(:subscription).permit(:plan, :card_number, :card_cvc, :card_expiry, :email, :name_on_card)
  end

  def subscription_id
    params['id']
  end

  def get_subscription
    Subscription.find subscription_id
  end

  def send_slack_notification(user, plan)
    url = 'https://hooks.slack.com/services/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'
    body = {
      text: "<https://dashboard.socialproofco.com/admin/users/#{user.id}|#{user.email}> switched to the #{plan} plan"
    }.to_json

    headers = {
      content_type: 'application/json'
    }

    RestClient.post(url, body, headers)
  end

  def update_getresponse_campaign(user)
    url = 'https://api.getresponse.com/v3/contacts'
    body = {
      email: user.email,
      campaign: {
        campaignId: 'TNbTF'
      },
      name: user.user_name,
      dayOfCycle: 0
    }.to_json

    headers = {
      content_type: 'application/json',
      x_auth_token: "api-key #{ENV['GET_RESPONSE_API_KEY']}"
    }

    response = RestClient.get("#{url}?query[email]=#{user.email}", headers)
    parsed_response = JSON.parse(response.body) if response.present?
    if parsed_response.count > 0
      get_response_contact = parsed_response.first if parsed_response.present?
      contact_id = get_response_contact["contactId"] if get_response_contact.present?
      RestClient.post("#{url}/#{contact_id}", body, headers) if contact_id.present?
    else
      RestClient.post(url, body, headers)
    end

  rescue RestClient::Conflict,
         RestClient::BadRequest
    Rails.logger.info "Unable to update #{user.email} in GetResponse"
  end
end
