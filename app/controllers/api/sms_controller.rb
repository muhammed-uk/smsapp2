# frozen_string_literal: true

module Api
  class SmsController < Api::ApiBaseController
    before_action :perform_validation!
    before_action :save_entry_to_cache, only: %i[inbound]

    def inbound
      render json: { message: 'Inbound SMS OK' }, status: :ok
    end

    def outbound
      render json: { message: 'Outbound SMS OK' }, status: :ok
    end

  private

    def perform_validation!
      action = params[:action].capitalize
      validator_class = "Sms::#{action}::#{action}Validator".constantize

      result = validator_class.call(
        current_user: current_user,
        params: params
      )

      unless result.success?
        render json: { message: '', errors: result.errors },
               status: :unprocessable_entity
      end
    end

    def save_entry_to_cache
      Sms::SaveToCache.call(params: params)
    end
  end
end
