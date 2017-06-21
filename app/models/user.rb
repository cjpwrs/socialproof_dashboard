class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :subscriptions

  attr_accessor :is_over_18

  validate :user_is_over_18

  def user_is_over_18
    errors.add(:is_over_18, "You must over 18") if is_over_18 == 'false'
  end

  def is_subscripted?
    self.subscriptions.any?
  end

  def lastest_subscription
    self.subscriptions.order(created_at: :asc).last
  end
end
