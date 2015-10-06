# cards-api

## Create Rails API and Database
1. `rails-api new cards-api --database=postgresql`
2. `cd cards-api`
3. `rails g model player fname lname hall_of_fame:boolean`
4. Add necessary null and defaults to the migration file:
  ```ruby
  class CreatePlayers < ActiveRecord::Migration
    def change
      create_table :players do |t|
        t.string :fname, null: false
        t.string :lname, null: false
        t.boolean :hall_of_fame, default: false

        t.timestamps null: false
      end
    end
  end
  ```
5. `rake db:create`
6. `rake db:migrate`
7. Add API routes:
  ```ruby
  Rails.application.routes.draw do
  
    namespace :api, defaults: {format: :json} do
      namespace :v1 do
        resources :players
      end
    end
    
  end
  ```
8. Create controller directory tree for the API:
  * controllers
    * api
      * v1
9. Add `gem resonders` to Gemfile so we can have access to the respond_to and respond_with controller methods.
10. `bundle install`
9. Create the **players_controller.rb** in the v1 directory:
  ```ruby
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
  ```
10. Create API access token model: `rails g model api_key access_token`
11. `rake db:migrate`
11. Add a generate_access_token method to the api_key model:
	```ruby
	class ApiKey < ActiveRecord::Base

		before_create :generate_access_token

		private

		def generate_access_token
		  begin
		    self.access_token = SecureRandom.hex
		  end while self.class.exists?(access_token: access_token)
		end
	
	end
	```
10. Run Rails console: `rails console`
12. Create API access token: `ApiKey.create!`
13. Locate created access token in console (i.e. `access_token: "a16db29eed8873da6faa24c232917690"`)
14. Create a player: `Player.create(fname:"George", lname:"Brett", hall_of_fame:true)`
15. `exit`
16. Start Rails server: `rails server`
17. Test API by viewing it with access token:
	`curl http://localhost:3000/api/v1/players -H 'Authorization: Token token="a16db29eed8873da6faa24c232917690"'`

