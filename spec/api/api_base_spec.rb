require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::ApiBaseController, type: :controller do
  controller do
    def test_exception_handling
      raise Timeout::Error
    end

    def test_auth
      render json: { message: 'authenticated successfully' }, status: :ok
    end
  end

  describe 'basic authentication' do
    before do
      routes.draw do
        post 'test_auth' => 'api/api_base#test_auth'
      end
    end

    context 'invalid credentials' do
      it 'should return unauthorized' do
        post :test_auth
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'valid credentials' do
      before { setup_accounts_and_numbers }

      it 'should return unauthorized' do
        request.headers.merge!(@headers)
        post :test_auth
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'exception handling' do
    before do
      routes.draw do
        post 'test_exception_handling' => 'api/api_base#test_exception_handling'
      end
    end

    context 'unknown error happens' do
      before { setup_accounts_and_numbers }

      it 'handles the exception' do
        request.headers.merge!(@headers)
        post :test_exception_handling
        expect(response).to have_http_status(500)
        expect(JSON.parse(response.body)['errors']).to eq(['Unknown Failure!'])
      end
    end
  end
end
