module Api
  module V1
    class UsersController < ApplicationController
      protect_from_forgery except: :create
      before_filter :authenticate
      respond_to :json

      def index
        render json: User.all, status: :ok
      end

      def show
        @user = User.find(params[:id])
        render json: @user
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user
        else
          render json: {message: 'failed', status: 500}
        end
      end

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :token)
      end

      protected
      def authenticate
        authenticate_or_request_with_http_token do |token, options|
          User.find_by(token: token)
        end
      end
    end
  end
end
