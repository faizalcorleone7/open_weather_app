require "#{Rails.root}/lib/errors/custom_api_error.rb"

class ApplicationController < ActionController::Base

  include Errors

  rescue_from StandardError, with: :render_standard_error
  #for any custom error which could be having 400, 401, 404, 422 error codes, it should be raised using CustomApiError in the application
  rescue_from Errors::CustomApiError, with: :render_error_api_response

  private

  def render_error_api_response(error)
    #byebug
    render json: {
      error: {
        title: error.title,
        message: error.message
      }
    }, status: error.code
  end

  def render_standard_error(error)
    #byebug
    render_error_api_response(CustomApiError.new(error.message, 500))
  end

end
