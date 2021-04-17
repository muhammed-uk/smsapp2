# frozen_string_literal: true

module Api
  class ApiBaseController < ApplicationController
    include ExceptionHandling
    include BasicAuthentication
  end
end
