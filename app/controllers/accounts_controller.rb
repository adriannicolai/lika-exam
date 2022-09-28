include UsersHelper
class AccountsController < ApplicationController
	def home_page

	end

	def register_page
	end

	def edit_page
		@user = User.get_user_record({ :fields_to_filter => { :id => session[:user_id] }})

		# redirect_to
	end

	def update_user_details
		response_data = { :status => false, :result => {}, :error => nil }

		begin
			update_user_details = User.update_user(params.merge!({"user_id" => session[:user_id] }))

			response_data.merge!(update_user_details)

			p response_data[:result]

			# Set the new user session if the creation of new user is successful
			set_user_session(response_data[:result].symbolize_keys!) if response_data[:status]
		rescue Exception=> ex
			response_data[:error] = ex.message
		end

		render :json => response_data
	end

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

	def login_page
	end

	def update_account
	end
end
