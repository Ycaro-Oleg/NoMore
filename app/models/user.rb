class User < ApplicationRecord
  has_secure_password

  has_many :commitments, dependent: :destroy
  has_many :focus_sessions, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
