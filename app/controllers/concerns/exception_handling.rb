# frozen_string_literal: true

module ExceptionHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |_error|
      render json: { errors: ['Unknown Failure!'] }, status: 500
    end
  end
end
