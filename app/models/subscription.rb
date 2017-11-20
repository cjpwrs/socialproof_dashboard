class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_type
  attr_accessor :stripe_card_token, :card_number, :card_expiry, :card_cvc, :card_address_zip, :email, :plan, :name_on_card

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(description: email, plan: plan_id, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end
