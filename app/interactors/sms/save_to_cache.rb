# frozen_string_literal: true

module Sms
  class SaveToCache
    include Interactor
    delegate :params, to: :context

    def call
      store_each_from_request
      store_blocked_request if params[:text] == 'STOP'
    end

    def store_each_from_request
      cache_key = "from-#{params[:from]}"
      body = {
        count: 1,
        expires_in: Time.now + 24.hours
      }
      write_to_cache(cache_key, body, 24.hours)
    end

    def store_blocked_request
      cache_key = "block-from-#{params[:from]}-to-#{params[:to]}"
      body = {
        from: params[:from],
        to: params[:to]
      }
      write_to_cache(cache_key, body, 4.hours)
    end

    def write_to_cache(key, body, expires_in)
      Rails.cache.write(key, body, expires_in: expires_in)
    end
  end
end
