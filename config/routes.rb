# frozen_string_literal: true

Rails.application.routes.draw do
  namespace 'api', constraints: { format: 'json' } do
    post '/inbound/sms', to: 'sms#inbound'
    post '/outbound/sms', to: 'sms#outbound'
  end

  match '/*path',
        to: proc { [405, {}, []] },
        via: %i[get post put patch delete]
end
