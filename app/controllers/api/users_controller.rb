class Api::UsersController < ApplicationController

  FIELDS_TO_RETURN = [:email, :phone_number, :full_name, :key, :account_key, :metadata]
  def index
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
    users = User.order(created_at: :desc)

    if params[:email].present?
      users = users.where(email: params[:email])
    end

    if params[:full_name].present?
      users = users.where("full_name LIKE ?", "%#{params[:full_name]}%")
    end

    if params[:metadata].present?
      users = users.where("metadata LIKE ?", "%#{params[:metadata]}%")
    end

    users = users.map do |user|
      user.as_json(only: FIELDS_TO_RETURN)
    end

    render json: { users: users }
  rescue ActionController::ParameterMissing
    render json: { errors: ['Invalid query parameters'] }, status: :unprocessable_entity
  end

  def create
    user = User.new(user_params)

    if user.save
      # TODO AccountKeyJob.perform_later(user.id)
      #
      render json: user.as_json(only: FIELDS_TO_RETURN), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid
    render json: { errors: ['Invalid user data'] }, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(:email, :phone_number, :full_name, :password, :metadata)
  end
end
