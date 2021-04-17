# frozen_string_literal: true

class OutboundRateLimiter
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO']&.include?('/api/outbound/sms')
      post_data = JSON.parse(env['rack.input'].read)
      from_address  = post_data['from']
      to_address    = post_data['to']

      if request_limit_reached?(from_address)
        error_message = "limit reached for from #{from_address}"
        return render_error_response(error_message)
      end

      if request_blacklisted?(from_address, to_address)
        error_message = "sms from #{from_address} to #{to_address} blocked by STOP request"
        return render_error_response(error_message)
      end

      env['rack.input'].rewind
    end

    @app.call(env)
  end

private

  def request_limit_reached?(from_address)
    limit_reached = false
    return limit_reached unless from_address.present?

    cache_key = "from-#{from_address}"
    cached_data = Rails.cache.read(cache_key)
    if cached_data.present?
      if cached_data[:count] <= 50
        remaining_time = (cached_data[:expires_in] - Time.now).round
        Rails.cache.write(cache_key,
                          { count: cached_data[:count] + 1,
                            expires_in: Time.now + remaining_time.seconds },
                          expires_in: remaining_time)
      else
        limit_reached = true
      end
    end

    limit_reached
  end

  def request_blacklisted?(from_address, to_address)
    blacklisted = false
    return blacklisted unless from_address.present? && to_address.present?

    cache_key = "block-from-#{from_address}-to-#{to_address}"
    cached_data = Rails.cache.read(cache_key)
    blacklisted = true if cached_data.present?

    blacklisted
  end

  def render_error_response(error_message)
    error_json = { message: '', errors: [error_message] }
    [429, { 'Content-Type' => 'application/json' }, [error_json.to_json]]
  end
end
