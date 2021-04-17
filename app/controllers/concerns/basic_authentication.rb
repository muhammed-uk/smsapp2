# frozen_string_literal: true

module BasicAuthentication
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_user

    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    before_action :authenticate_user!
  end

private

  def authenticate_user!
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = Account.find_by(username: username)
      return true if current_user.try(:auth_id) == password

      false
    end
  end
end
