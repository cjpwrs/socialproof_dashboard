class User < ApplicationRecord
  require 'net/http'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :subscriptions

  attr_accessor :is_over_18, :instagram_account, :instagram_password, :growth_performance

  validate :user_is_over_18

  before_save :generate_stim_token
  before_save :update_account_id

  def generate_stim_token
    if self.stim_account == 'ridingjay'
      api_key = ENV['JAY_STIM_API_KEY']
    else
      api_key = ENV['STIM_API_KEY']
    end
    url = URI.parse("https://stimsocial.com/index.php?route=api/login&key=#{api_key}")
    stim_response = url.read
    return unless stim_response.present?
    stim_response = eval(stim_response)
    if stim_response[:success].present? && stim_response[:success] && stim_response[:token].present?
      self.stim_token = stim_response[:token]
    end
  end

  def refresh_stim_token
    generate_stim_token
    save!
  end

  def update_account_id
    if self.stim_response.present? && self.stim_response['account_id'].present?
      self.account_id = self.stim_response['account_id']
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
