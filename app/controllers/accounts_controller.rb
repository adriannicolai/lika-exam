include UsersHelper
class AccountsController < ApplicationController
	before_action :check_user_session, except: [:register_page, :register, :login_page, :login]


	# DOCU: This is the home page
    # Triggered by: (GET) /accounts/home_page
	# Session - first_name, last_name, email
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def home_page
	end

	# DOCU: This is the register page
    # Triggered by: (GET) /accounts/register_page
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def register_page
	end

	# DOCU: This is the edit page
    # Triggered by: (GET) /accounts/edit_page
	# Session - user_id
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def edit_page
		@user = User.get_user_record({ :fields_to_filter => { :id => session[:user_id] }})
	end

	# DOCU: This is the method for updating user details
    # Triggered by: (POST) /accounts/update_account
	# Session - user_id
	# Params - first_name, last_name, email, update_type
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def update_user_details
		response_data = { :status => false, :result => {}, :error => nil }

		begin
			update_user_details = User.update_user(params.merge!({"user_id" => session[:user_id] }))

			response_data.merge!(update_user_details)

			# Set the new user session if the creation of new user is successful
			set_user_session(response_data[:result].symbolize_keys!) if response_data[:status]
		rescue Exception=> ex
			response_data[:error] = ex.message
		end

		render :json => response_data
	end

	# DOCU: This is the method for creating a new user
    # Triggered by: (POST) /accounts/register
	# Params - first_name, last_name, email, update_type
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def register
		response_data = { :status => false, :result => {}, :error => nil }

		begin
			create_user_record = User.create_user(params)

			# Merge the response
			response_data.merge!(create_user_record)

			# Set the new user session if the creation of new user is successful
			set_user_session(response_data[:result].symbolize_keys!) if response_data[:status]
		rescue Exception=> ex
			response_data[:error] = ex.message
		end

		render :json => response_data
	end

	# DOCU: This is the method rendering the login page
    # Triggered by: (GET) /accounts/login_page
	# Params - email, password
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def login_page
	end

	# DOCU: This is the processing the login of user
    # Triggered by: (POST) /accounts/login_page
	# Params - email, password
    # Last updated at: September 28, 2022
    # Owner: Adrian
	def login
		response_data = { :status => false, :error => {}, :error => nil }

		begin
			login_user = User.login_user(params)

			response_data.merge!(login_user)

			# Set the new user session if the creation of new user is successful
			set_user_session(response_data[:result].symbolize_keys!) if response_data[:status]
		rescue Exception => ex
			response_data[:error] = ex.message
		end

		render :json => response_data
	end

	# DOCU: Redirects the user to the sign up page and clears the session
	# Triggered by before_action
	# Session: session - user_id
	# Last udpated at: September 28, 2022
	# Owner:  Adrian
	def logout
		reset_session

		redirect_to "/"
	end

	private
		# DOCU: Redirects the user to the home page if there is no session
		# Triggered by before_action
		# Session: session - user_id
		# Last udpated at: September 28, 2022
		# Owner:  Adrian
		def check_user_session
			redirect_to "/" if !session[:user_id].present?
		end
end
