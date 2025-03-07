class User < ApplicationRecord
  include APIAuthenticatable
  include PayCustomer

  devise :confirmable,
    :database_authenticatable,
    :recoverable,
    :registerable,
    :rememberable,
    :validatable

  has_many :notification_tokens
  has_many :notifications, as: :recipient, dependent: :destroy
  has_one :business, dependent: :destroy
  has_one :developer, dependent: :destroy

  has_many :conversations, ->(user) {
    unscope(where: :user_id)
      .left_joins(:business, :developer)
      .where("businesses.user_id = ? OR developers.user_id = ?", user.id, user.id)
      .visible
  }
  has_many :unread_conversations,
    class_name: :Conversation,
    foreign_key: :user_with_unread_messages_id,
    inverse_of: :user_with_unread_messages

  scope :admin, -> { where(admin: true) }

  # Always remember when signing in with Devise.
  def remember_me
    Rails.configuration.always_remember_me
  end
end
