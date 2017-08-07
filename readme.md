# API tutorial - build an api consumer app 
(part 2)

<font color="red">Note: I've created a sample API_provider application in [this post](https://github.com/thefonso/api_provider/blob/master/readme.md). We will use that app later in this tutorial</font>

In this tutorial I'll show you how to create an API_consumer app to register, update or delete a user on the API_provider app database.

You can see that the API_provider has documented the url, authentication, expected data type and data required to fulfil your request. As long as you can provide those criteria, you can write your API_consumer code in any language. Here I will stick to Ruby.

Ruby has an inbuilt library to manage making API calls, retrieving the returned response, and parsing it to reuse it in your own application. Here are links to those libraries.

[http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html](http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html)

[http://rubydoc.info/gems/rest-client/1.6.3/RestClient](http://rubydoc.info/gems/rest-client/1.6.3/RestClient)

You could use the above two libraries to write your API_consumer class. However the ruby community has a number of Gems available to help you with this already, some of them are : rest-client , faraday and httparty. For this lesson we will use the rest-client gem.

Now Let us make an application which will consume the API that I've developed in my other post(SEE LINK AT TOP OF PAGE). The API provides functionality to manage a user, so in our application we will not store a user in our own database, but will register it, update and delete it with the API_consumer app.

I am assuming that you have implemented a users controller at some point of time, where you have implemented **index , new, create, edit, update and destroy method**. Here the view, routes and everything remain the same, only the Users controller code will change, as now, it will interact, not with your local Database, but with the API_provider app Database.

Let us create our Rails Application, which will consume the user management API

**STEP 1: generate the rails app**

	$ rails _3.2.13_ new api_consumer_pg -T -d=postgresql


**STEP 2: add rest-client gems to your Gemfile**

<font color="blue">gem 'rest-client'</font>

run bundle install on the terminal

<font color="red">$ bundle install</font>

**STEP 3: create the database and generate the user controller**

	$ rake db:create
	$ rails g controller users

**STEP 4: add the routes for users resource in your routes**

	ApiConsumer::Application.routes.draw do
		resources :users
	end


**STEP 5: Write the users controller code.**

Users controller will have the same actions and flow as you have seen in your users controller, except that, here you interact with the API provider database through its API call. IF you see the API provider document, you can see that it has provided you the authentication login, the url, and the expected data format.

You just have to make a call to this URL and handle the returned data in your application. Now-a-days API return data is in json format in general, but in case they return data in some other format say SOAP, then you have to adjust your code accordingly. The API provider whose service we are going to use returns JSON data by default i.e. if you do not provide a format in the URL, it will return JSON data.

So below is our **users_controller.rb** code:

<font color="red">NOTE : See the use of **get post put** and **delete** call of the REST client. It will decide which action of the API provider will be called for a certain URL</font>

	class UsersController < ApplicationController
	  require 'rest_client'

	  USERNAME = "thefonso" # needed to access the APi
	  PASSWORD = "rebelbase" # needed to access the APi
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
	      redirect_to users_path # redirect back to index page, which now list the newly created user
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

**STEP 6 : Create the corresponding views for the controller action**

**index.html.erb**

It will list all the user detail returned by the API, it will provide a “create new user” link to create a new user, also each record will have an Edit | Delete link. Clicking the edit link will take the user to the edit page where they will modify their detail and the Delete action will delete the user.

	<%= link_to "Create New User", new_user_path %>
	<%if @users.present? %>
	  <p>Below is the list of users</p>
	  <table width="100%">
	    <tr>
	      <td>ID</td>
	      <td>first_name</td>
	      <td>last_name</td>
	      <td>email</td>
	      <td>Action</td>
	    </tr>
	    <!-- NOTE : the @users object in our index action is an array of hash, which is generated 
	    when we passed return data to the JSON.parse method. If you handled data in some other
	    way, modify the code below accordingly. Say for xml data you have to use something like
	    u.xpath("id").text instead of u[:id] -->
	    <%@users.each do |u|%>
	    <tr>
	      <td><%=u[:id]%></td>
	      <td><%=u[:first_name]%></td>
	      <td><%=u[:last_name]%></td>
	      <td><%=u[:email]%></td>
	      <td>
	        <%= link_to "Edit", edit_user_path(u[:id]) %> | 
	        <%= link_to "Delete", user_path(u[:id]), :method => :delete %>
	      </td>
	    </tr>
	   <%end%>
	  </table>
	<%else%>
	  <p>No User is Found</p>
	<%end%>

**new.html.erb**

Here, as usual, a user will fill up her details and on pressing submit the form will call the create action (via post) of the API and create the new user.

	<%= form_tag users_path, :method => :post do %>
	   email : <%=text_field_tag :email%><br />
	   first_name :<%=text_field_tag :first_name%><br />
	   last_name :<%=text_field_tag :last_name%><br/><br/>
	   <%=submit_tag "save"%>
	<%end%>

**edit.html.erb**

User will modify, there details and submit to the update action, which in turn updates the record on the API_provider app database.

	<%= form_tag user_path, :method => :put do %>
	   email : <%=text_field_tag :email, @user[:email]%><br />
	   first_name :<%=text_field_tag :first_name, @user[:first_name]%><br />
	   last_name :<%=text_field_tag :last_name, @user[:last_name]%><br/><br/>
	   <%=submit_tag "update"%>
	<%end%>

**STEP 7 : see it working**

Now for the fun part. To see this in action you will need to start both the API_provider and API_consumer applications on your local machine...

Start the API provider application on 3000 (the default port).

$ cd to_api_provider_folder

$ rails s # will start the API provider service at port 3000

**NOTE: For API consumer code to work, The API provider application must be up and running**

Start the API consumer application on some other port, say 3030

$ cd api_consumer

$ rails s -p 3030

Go to the index page of the application:

http://localhost:3030/users # this will show you all users with an edit | delete link and also a create new user link. 
Any remaining things are self explainatory. I hope this usefull!

View tutorial readme pages / code:

part 1 - [Build an API provider](https://github.com/thefonso/api_provider/)

part 2 - [a REST client for Firefox here](https://github.com/thefonso/api_provider/blob/master/rest_firefox_client.md)

part 3 - [How to build a REST client](https://github.com/thefonso/api_consumer/)
