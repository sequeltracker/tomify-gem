module Tomify::Concerns::User
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
    has_many :tokens, dependent: :destroy

    before_validation :format_email
    after_create :send_invite, unless: :password_digest

    validates_presence_of :email, :first_name, :last_name
    validates_uniqueness_of :email
    validates_format_of :email, with: /@/i
    validates_length_of :password, minimum: 8, allow_blank: true, on: :create
    validates_confirmation_of :password, allow_blank: true, on: :create

    default_scope { order(:created_at) }
    scope :admin, -> { where(admin: true) }
  end

  class_methods do
    def admin_params
      [:admin, :email, :first_name, :last_name]
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def serializable_hash(options = nil)
    options ||= {}
    super({ methods: [:name] }.update(options))
  end

  private
  def format_email
    self.email = email.try(:strip).try(:downcase)
  end

  def send_invite
    Tomify::UserMailer.invite(self).deliver_now
  end
end
