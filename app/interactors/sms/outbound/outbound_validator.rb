# frozen_string_literal: true

module Sms
  module Outbound
    class OutboundValidator < Sms::BaseParamsValidator
      def call
        super
        check_limit_reached
        check_blacklisted
      end

    private

      def check_for_phone_number; end

      def check_limit_reached
        return unless params[:from].present?

        cache_key = "from-#{params[:from]}"
        cached_data = Rails.cache.read(cache_key)
        return unless cached_data.present?

        if cached_data[:count] <= OUTBOUND_REQ_LIMIT.to_i
          remaining_time = (cached_data[:expires_in] - Time.now).round
          Rails.cache.write(cache_key,
                            { count: cached_data[:count] + 1,
                              expires_in: Time.now + remaining_time.seconds },
                            expires_in: remaining_time)
        else
          context.fail!(errors: ["limit reached for from #{params[:from]}"])
        end
      end

      def check_blacklisted
        return unless params[:from].present? && params[:to].present?

        cache_key = "block-from-#{params[:from]}-to-#{params[:to]}"
        cached_data = Rails.cache.read(cache_key)
        return unless cached_data.present?

        context.fail!(
          errors: ["SMS from #{params[:from]} to #{params[:to]} blocked by STOP request"]
        )
      end
    end
  end
end
