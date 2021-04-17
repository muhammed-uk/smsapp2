require 'rails_helper'
require 'spec_helper'

module Sms
  RSpec.describe BaseParamsValidator do
    let(:valid_params) do
      {
        from: '8075307117',
        to: '9746473595',
        text: 'Helo'
      }
    end

    describe '.call' do
      context 'negative scenarios' do
        context 'check for required fields' do
          context 'all required fields are missing' do
            it 'should display missing fields' do
              response = described_class.call(params: {})
              validation_errors = ['from is missing', 'to is missing', 'text is missing']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end
          end

          context 'one required fields is missing' do
            it 'should display missing field' do
              params = valid_params.except(:from)
              response = described_class.call(params: params.as_json)
              validation_errors = ['from is missing']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end
          end
        end

        context 'fields validation' do
          context 'field: from' do
            it 'should mention from is invalid when from is not a string type' do
              params = valid_params
              params[:from] = true
              response = described_class.call(params: params.as_json)
              validation_errors = ['from is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when min length is not satisfied' do
              params = valid_params
              params[:from] = '1'
              response = described_class.call(params: params.as_json)
              validation_errors = ['from is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when max length is not exceeded' do
              params = valid_params
              params[:from] = '10101010101010101010101'
              response = described_class.call(params: params.as_json)
              validation_errors = ['from is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end
          end

          context 'field: to' do
            it 'should mention to is invalid when to is not a string type' do
              params = valid_params
              params[:to] = true
              response = described_class.call(params: params.as_json)
              validation_errors = ['to is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when min length is not satisfied' do
              params = valid_params
              params[:to] = '1'
              response = described_class.call(params: params.as_json)
              validation_errors = ['to is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when max length is not exceeded' do
              params = valid_params
              params[:to] = '10101010101010101010101'
              response = described_class.call(params: params.as_json)
              validation_errors = ['to is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end
          end

          context 'field: text' do
            it 'should mention text is invalid when text is not a string type' do
              params = valid_params
              params[:text] = true
              response = described_class.call(params: params.as_json)
              validation_errors = ['text is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when min length is not satisfied' do
              params = valid_params
              params[:text] = ''
              response = described_class.call(params: params.as_json)
              validation_errors = ['text is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end

            it 'should mention from is invalid when max length is not exceeded' do
              params = valid_params
              params[:text] = 'hi' * 100
              response = described_class.call(params: params.as_json)
              validation_errors = ['text is invalid']
              expect(response.success?).to eq(false)
              expect(response.errors).to eq(validation_errors)
            end
          end
        end

        context 'check_for_phone_number' do
          before { @user = create(:account) }

          it 'should display error when phone number is not found in the current users contacts' do
            params = valid_params
            response = described_class.call(params: params.as_json, current_user: @user)
            validation_errors = ["#{params[:to]} not found"]
            expect(response.success?).to eq(false)
            expect(response.errors).to eq(validation_errors)
          end
        end
      end

      context 'positive scenario' do
        before do
          @user = create(:account)
          create(:phone_number, account: @user, number: '9746473595')
        end

        it 'should return success' do
          response = described_class.call(
            params: valid_params.as_json,
            current_user: @user
          )
          expect(response.success?).to eq(true)
          expect(response.errors).to be_nil
        end
      end
    end
  end
end
