module Tomify::Concerns::User
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
    has_many :tokens, class_name: Tomify.models.token.to_s, dependent: :destroy

    before_validation :format_email
    after_create :send_invite, if: :invited
    after_create :send_welcome, unless: :invited

    validates_presence_of :email, :first_name, :last_name
    validates_uniqueness_of :email, allow_blank: true
    validates_format_of :email, with: /@/i, allow_blank: true
    validates_length_of :password, minimum: 8, allow_blank: true
    validates_confirmation_of :password, allow_blank: true
    validate :subscribed, on: :create, if: :invited

    default_scope { order(:created_at) }
    scope :admin, -> { where(admin: true) }
  end

  class_methods do
    def admin_params
      [:admin, :email, :first_name, :last_name]
    end

    def public_params
      [:email, :first_name, :last_name, :password, :password_confirmation]
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def subscription
    Tomify.models.subscription.find_or_create_by(email: email)
  end

  def token(name = nil)
    tokens.find_or_create_by(name: name)
  end

  def serializable_hash(options = nil)
    options = { methods: [:name] } if options.blank?
    super options
  end

  private
  def format_email
    self.email = email.try(:strip).try(:downcase)
  end

  def subscribed
    errors.add :invited, "email has unsubscribed" if errors.blank? && subscription.inactive
  end

  def send_invite
    Tomify.mailers.user.invite(self).deliver_now if subscription.active
  end

  def send_welcome
    Tomify.mailers.user.welcome(self).deliver_now if subscription.active
  end
end
