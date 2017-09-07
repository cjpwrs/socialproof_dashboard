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
      ENV['PRO_PLUS_COUPON']
    elsif plan.name == 'PRO'
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
      update_getresponse_campaign(current_user)
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
    @stripe_subscription_json = Stripe::Subscription.retrieve @subscription.stripe_subscription_id
    if @stripe_subscription_json.status == 'canceled'
      redirect_to new_subscription_path
    else
      @upcoming_invoice = Stripe::Invoice.upcoming(:customer => @stripe_subscription_json.customer)
      @card = Stripe::Customer.retrieve(@stripe_subscription_json.customer).sources.data
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
    params.require(:subscription).permit(:plan, :stripe_card_token)
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
