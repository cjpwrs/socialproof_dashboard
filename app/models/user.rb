class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :subscriptions

  def is_subscripted?
    self.subscriptions.any?
  end

  def lastest_subscription
    self.subscriptions.order(created_at: :asc).last
  end
end
