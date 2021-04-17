module SupportHelper
  def setup_accounts_and_numbers
    @user = FactoryBot.create(:account)
    5.times do |n|
      FactoryBot.create(:phone_number, account: @user)
    end
    credentials = [@user.username, @user.auth_id]
    encoded_basic_auth = ActionController::HttpAuthentication::Basic.encode_credentials(*credentials)
    @headers = {
      'ACCEPT' => 'application/json',
      'Authorization' => encoded_basic_auth
    }
  end
end
