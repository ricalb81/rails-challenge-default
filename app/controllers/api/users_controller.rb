class Api::UsersController < ApplicationController

  ActionController::Parameters.action_on_unpermitted_parameters = :raise
  FIELDS_TO_RETURN = [:email, :phone_number, :full_name, :key, :account_key, :metadata]
  def index
    users = User.order(created_at: :desc)

    users = users.where(email: list_params[:email]) if list_params[:email].present?
    users = users.where("full_name LIKE ?", "%#{list_params[:full_name]}%") if list_params[:full_name].present?
    users = users.where("metadata LIKE ?", "%#{list_params[:metadata]}%") if list_params[:metadata].present?

    users = users.map do |user|
      user.as_json(only: FIELDS_TO_RETURN)
    end

    render json: { users: users }
  rescue ActionController::UnpermittedParameters => error
    render json: { errors: ['Invalid query parameters'] }, status: :unprocessable_entity
  end

  def create
    user = User.new(user_params)
    user.save!

    render json: user.as_json(only: FIELDS_TO_RETURN), status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def list_params
    params.permit(:email, :full_name, :metadata)
  end

  def user_params
    params.require(:user).permit(:email, :phone_number, :full_name, :password, :metadata)
  end
end
