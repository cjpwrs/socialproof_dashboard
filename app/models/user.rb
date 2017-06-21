class User < ApplicationRecord
  require 'net/http'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :subscriptions

  attr_accessor :is_over_18, :instagram_account, :instagram_password

  validate :user_is_over_18

  before_save :generate_stim_token

  def generate_stim_token
    url = URI.parse("https://stimsocial.com/index.php?route=api/login&key=#{ENV['STIM_API_KEY']}")
    stim_response = url.read
    return unless stim_response.present?
    stim_response = eval(stim_response)
    if stim_response[:success].present? && stim_response[:success] && stim_response[:token].present?
      self.stim_token = stim_response[:token]
    end
  end

  def user_is_over_18
    errors.add(:is_over_18, "You must over 18") if is_over_18 == 'false'
  end

  def is_subscripted?
    if self.subscriptions.any? && self.subscriptions.order(id: :asc).last.status == 'active'
      return true
    else
      return false
    end
  end

  def lastest_subscription
    self.subscriptions.order(created_at: :asc).last
  end
end
