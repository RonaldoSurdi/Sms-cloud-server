class Api::BaseController < ApplicationController
  TOKEN = "226a4473e70f49f959f8"

  before_action :restrict_access
  skip_before_action :verify_authenticity_token

  private

  def restrict_access
    # Manter compatibilidade com API
    return true if request.headers[:authorization] == "Basic YWRtaW5Ad29sZi5jb20uYnI6Y29ubmVjdDEyMw=="

    authenticate_or_request_with_http_token do |token, options|
      token == TOKEN
    end
  end
end