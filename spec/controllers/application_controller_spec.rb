require "rails_helper"

describe ApplicationController do
  before(:all) do
    LocationPollutionRecord.delete_all
    Location.delete_all

    class TestController < ApplicationController
      def standard_error_route
        raise "This is a Standard Error"
      end

      def bad_request_error_route
        raise CustomApiError.new("Bad request error route", 400)
      end

      def unauthorised_error_route
        raise CustomApiError.new("Unauthorised error route", 401)
      end

      def forbidden_error_route
        raise CustomApiError.new("Forbidden error route", 403)
      end

      def not_found_error_route
        raise CustomApiError.new("Not found error route", 404)
      end

      def non_proccessible_route
        raise CustomApiError.new("Unprocessible entity route", 422)
      end

      def internal_server_error_route
        raise CustomApiError.new("Internal server error route", 500)
      end
    end

    Rails.application.routes.draw do
      get "tests/standard_error_route", to: "test#standard_error_route"
      get "tests/bad_request_error_route", to: "test#bad_request_error_route"
      get "tests/unauthorised_error_route", to: "test#unauthorised_error_route"
      get "tests/forbidden_error_route", to: "test#forbidden_error_route"
      get "tests/not_found_error_route", to: "test#not_found_error_route"
      get "tests/non_proccessible_route", to: "test#non_proccessible_route"
      get "tests/internal_server_error_route", to: "test#internal_server_error_route"
    end

    @controller = TestController.new

  end

  after(:all) do
    Rails.application.reload_routes!
    LocationPollutionRecord.delete_all
    Location.delete_all
  end

  context "Check general error handling" do

    def response_body(response)
      JSON.parse(response.body)
    end

    it "should handle standard error" do
      get :standard_error_route
      expect(response.status).to eq(500)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Internal Server Error", "message"=>"This is a Standard Error"}})
    end

    it "should handle bad request error" do
      get :bad_request_error_route
      expect(response.status).to eq(400)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Bad Request Error", "message"=>"Bad request error route"}})
    end

    it "should handle unauthorized error" do
      get :unauthorised_error_route
      expect(response.status).to eq(401)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Unauthorized Error", "message"=>"Unauthorised error route"}})
    end

    it "should handle forbidden error" do
      get :forbidden_error_route
      expect(response.status).to eq(403)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Forbidden Error", "message"=>"Forbidden error route"}})
    end

    it "should handle not found error" do
      get :not_found_error_route
      expect(response.status).to eq(404)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Not Found Error", "message"=>"Not found error route"}})
    end

    it "should handle unprocessible entity error" do
      get :non_proccessible_route
      expect(response.status).to eq(422)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Unporcessible Entity Error", "message"=>"Unprocessible entity route"}})
    end

    it "should handle internal server error" do
      get :internal_server_error_route
      expect(response.status).to eq(500)
      expect(response_body(response)).to eq({"error"=>{"title"=>"Internal Server Error", "message"=>"Internal server error route"}})
    end

  end
end
