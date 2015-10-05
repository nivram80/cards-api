module Api
  module V1
    class PlayersController < ApplicationController
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include ActionController::ImplicitRender

      before_filter :restrict_access
      respond_to :json

      def index
        respond_with(Player.all.order("created_at DESC"))
      end

      def show
        respond_with(Player.find(params[:id]))
      end

      def create
        @player = Player.new(players_params)
        if @player.save
          respond_to do |format|
            format.json { render :json => @player }
          end
        end
      end

      def update
        @player = Player.find(params[:id])
        if @player.update(players_params)
          respond_to do |format|
            format.json { render :json => @player }
          end
        end
      end

      def destroy
        respond_with(Player.destroy(params[:id]))
      end

    private

      def players_params
        params.require(:player).permit(:fname, :lname, :hall_of_fame)
      end

      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
      
    end
  end
end
