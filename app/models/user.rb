class User < ApplicationRecord
  require 'net/http'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :subscriptions

  attr_accessor :is_over_18

  validate :user_is_over_18

  before_save :generate_stim_token

  def generate_stim_token
    url = URI.parse('https://stimsocial.com/index.php?route=api/login&key=ADimqAOHfQaKhXK4uSIIOOR4DlsHOJw7v2W5FtekF1Lexsnaq6Uxgqf1bpn7h6idmV7R62rw1QuplgEAo6UbZaTNsZUPlkgDb2w8jeTtELDVlU0yDNpeDP4C0pa5uLTG2VpwNMmpQ1aTeW45XGIpPoR7ZrLOPpe1BAFDoruzDKIUwJ6UG6wzxUye6yPyn0jEqOJ7MDPaxsZrUuW2Ro2Bi2HN2ltTlP6IfiXqqMKKEXVBNrRB6iROIV6LTrOEER7o')
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
    self.subscriptions.any?
  end

  def lastest_subscription
    self.subscriptions.order(created_at: :asc).last
  end
end
