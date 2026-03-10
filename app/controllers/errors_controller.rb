class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def not_found
    render "errors/404", status: 404
  end

  def server_error
    render "errors/500", status: 500
  end
end
