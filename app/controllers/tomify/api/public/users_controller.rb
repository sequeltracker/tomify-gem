class Tomify::Api::Public::UsersController < Tomify.controllers.public_api
  before_action :require_user!, only: [:show, :update]
  before_action :set_record, only: [:show, :update, :destroy]
  before_action :not_found, only: :create, unless: "setting(:allow_signup)"

  def create
    session[:current_user_id] = Tomify.models.user.create!(record_params).id
    render json: { type: :success }, success: "Welcome #{current_user.name}!"
  rescue ActiveRecord::RecordInvalid => e
    render json: { type: :warning, message: e.record.errors.full_messages.join(", ") }
  end

  def update
    current_user.update!(record_params)
    render json: { type: :success, message: "Profile Updated" }
  rescue ActiveRecord::RecordInvalid => e
    render json: { type: :warning, message: e.record.errors.full_messages.join(", ") }
  end

  def destroy
    flash[:danger] = "Goodbye #{current_user.name}"
    find_record
    destroy_record
    render json: { type: :success }
  end

  private
  def set_record
    @record = current_user
  end
end
