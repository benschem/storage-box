class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :houses, optional: true
  has_many :items
  has_many :rooms, through: :houses
  has_many :boxes, through: :rooms
  has_many :tags

  validates :name, presence: true
  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    presence: true,
    uniqueness: { case_insensitive: true }

  # validate :password_complexity

  # private

  # def password_complexity
  #   if password.present? and !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{12,}$/)
  #     errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit, and needs to be minimum 12 characters."
  #   end
  # end
end
