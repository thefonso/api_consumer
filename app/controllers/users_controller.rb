class UsersController < ApplicationController
	require 'rest_client'

	USERNAME = 'thefonso'
	PASSWORD = 'rebelbase'

	API_BASE_URL = "http://localhost:3000/api" # base url of the API
	def index
		# specifying json format in the URl
	    uri = "#{API_BASE_URL}/users.json"
	    # It will create new rest-client resource so that we can call different methods of it
	    rest_resource = RestClient::Resource.new(uri, USERNAME, PASSWORD)

	    # this next line will give you back all the details in json format, 
	    #but it will be wrapped as a string, so we will parse it in the next step.
	    users = rest_resource.get 

	    # we will convert the return data into an array of hash. see json data parsing here
	    @users = JSON.parse(users, :symbolize_names => true)
	end

	def new
		
	end

	def create
	    uri = "#{API_BASE_URL}/users"
	    payload = params.to_json # converting the params to json
	    rest_resource = RestClient::Resource.new(uri, USERNAME, PASSWORD)
	    begin
			rest_resource.post payload , :content_type => "application/json"
			flash[:notice] = "User Saved successfully"
			redirect_to users_path # take back to index page, which now list the newly created user
	    rescue Exception => e
			flash[:error] = "User Failed to save"
			render :new
    	end
  	end

	def edit
	    uri = "#{API_BASE_URL}/users/#{params[:id]}.json" # specifying format as json so that 
	                                                      #json data is returned 
	    rest_resource = RestClient::Resource.new(uri, USERNAME, PASSWORD)
	    users = rest_resource.get
	    @user = JSON.parse(users, :symbolize_names => true)
	end

	def update
	    uri = "#{API_BASE_URL}/users/#{params[:id]}"
	    payload = params.to_json
	    rest_resource = RestClient::Resource.new(uri, USERNAME, PASSWORD)
	    begin
			rest_resource.put payload , :content_type => "application/json"
			flash[:notice] = "User Updated successfully"
	    rescue Exception => e
			flash[:error] = "User Failed to Update"
	    end
	    redirect_to users_path
	end

	def destroy
	    uri = "#{API_BASE_URL}/users/#{params[:id]}"
	    rest_resource = RestClient::Resource.new(uri, USERNAME, PASSWORD)
	    begin
	    	rest_resource.delete
	    	flash[:notice] = "User Deleted successfully"
	    rescue Exception => e
	    	flash[:error] = "User Failed to Delete"
	    end
	    redirect_to users_path
	end
end