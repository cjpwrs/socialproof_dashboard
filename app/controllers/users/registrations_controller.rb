class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @subscription = Subscription.new
    @stripe_list = Stripe::Plan.all
    @plans = @stripe_list[:data].map{ |plan|
       if plan[:name] == 'STARTER'
        [plan[:name] + ' - ' +  '$9 for 30 days. After 30 days, $24/month', plan[:id]]
       else
        [plan[:name] + ' - ' +  (plan[:amount].to_f/100).to_s + '/month', plan[:id]]
        end
    }
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
        format.html { redirect_to dashboard_path }
        format.json { render json: {success: true} }
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
