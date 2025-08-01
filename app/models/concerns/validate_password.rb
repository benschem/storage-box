# frozen_string_literal: true

# ValidatePassword concern to extract password logic out of User.
module ValidatePassword
  extend ActiveSupport::Concern

  included do
    validate :password_complexity
  end

  private

  def password_complexity
    return if password.blank?

    # Devise validates a minimum length.
    # Set it in `config/initializers/devise.rb`
    one_lowercase_letter
    one_uppercase_letter
    one_digit
  end

  def one_lowercase_letter
    errors.add :password, 'must include at least one lowercase letter.' unless password.to_s.match?(/[a-z]/)
  end

  def one_uppercase_letter
    errors.add :password, 'must include at least one uppercase letter.' unless password.to_s.match?(/[A-Z]/)
  end

  def one_digit
    errors.add :password, 'must include at least one digit.' unless password.to_s.match?(/\d/)
  end
end
