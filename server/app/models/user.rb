include QueryHelper
include ApplicationHelper
include UsersHelper

class User < ApplicationRecord
    # DOCU: Method to insert new account
    # Triggered by: AccountsController
	# Requires: params - first_name, last_name, email, password, confirm_password
    # Returns: { status: true/false, result: { user_details }, error }
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def self.create_user(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            # Validate for reqired fields
            check_user_params = check_fields(["first_name", "last_name", "email", "password", "confirm_password"], [], params)

            # Validate for user information
            if check_user_params[:status]
                validate_user_details = validate_new_user_info(check_user_params[:result])

                # destructure user_params
                first_name, last_name, email, password = check_user_params[:result].values_at(:first_name, :last_name, :email, :password)


                if validate_user_details[:status]
                    create_new_user = insert_record(["
                        INSERT INTO users (first_name, last_name, email, password, is_admin, created_at, updated_at)
                        VALUES (?, ?, ?, ?, ?, NOW(), NOW())
                    ", first_name, last_name, email, encrypt_password(password), USER_LEVEL_ID[:admin]])

                    if create_new_user.present?
                        response_data[:status] = true
                        response_data[:result] = self.get_user_record({ :fields_to_filter => { :id => create_new_user }})[:result]
                    else
                        response_data[:error] = "Something went wrong with creating a new user, Please try again later"
                    end
                else
                    response_data.merge!(validate_user_details)
                end
            else
                response_data.merge!(check_user_params)
            end

        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end

    # DOCU: Method to update user
    # Triggered by: AccountsController
	# Requires: params - first_name, last_name, email, password, confirm_password
    # Returns: { status: true/false, result: { user_details }, error }
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def self.update_user(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            case params[:update_type].to_i
            when USER_UPDATE_TYPES[:details]
                response_data.merge!(self.update_user_details(params))
            when USER_UPDATE_TYPES[:password]
                # TODO: Add user updating of password scenarios are
                # incorrect password
                # incorrect password pattern
                # same old password and new password
                # passwords do not match
            else
                response_data.merge!({ :error => "Invalid Action" })
            end
        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end

     # DOCU: Method to login user
    # Triggered by: AccountsController
	# Requires: params - email, password
    # Returns: { status: true/false, result, error }
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def self.login_user(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            # Check fields for login user
            check_login_user_parameters = check_fields(["email", "password"], [], params)

            # Guard clause for check_login_user_parameters
            raise check_login_user_parameters[:error] if !check_login_user_parameters[:status]

            # Destructure check_login_user_parameters
            email, password = check_login_user_parameters[:result].values_at(:email, :password)

            # Get user_data
            user_details = self.get_user_record({
                :fields_to_filter => { :email => email, :password => encrypt_password(password)},
                :fields_to_select => "id, first_name, last_name, email"
            })

            response_data.merge!(user_details)
        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end
    # DOCU: Method to route the update user details
    # Triggered by: AccountsController
	# Requires: params - first_name, last_name, email, password, confirm_password
    # Returns: { status: true/false, result: { user_details }, error }
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def self.update_user_details(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            # Check parameters for updating user details
            check_user_details_parameters = check_fields(["user_id", "first_name", "last_name", "email"], [], params)

            # Guard clause for checking user details parameters
            raise check_user_details_parameters[:error] if !check_user_details_parameters[:status]

            # Desctructure check_user_details_parameters
            user_id, first_name, last_name, email = check_user_details_parameters[:result].values_at(:user_id, :first_name, :last_name, :email)

            # Check if user with duplicate eemmail is exisitng
            duplicate_email = self.get_user_record({:fields_to_filter => { :email => email }})

            # downcase the email
            email.downcase!

            # Checker for emailk pattern
            raise "Incorrect email pattern" if (email =~ URI::MailTo::EMAIL_REGEXP).nil?

            # Update the user if there are no duplcate email from the db
            if duplicate_email[:error] === "User not found" || email === duplicate_email[:result]["email"]
                update_user_details = self.update_user_record({
                    :fields_to_filter => { :id => user_id },
                    :fields_to_update => { :first_name => first_name, :last_name => last_name, :email => email }
                })

                # Fetch the user and return the status of true if updating is successful
                if update_user_details[:status]
                    response_data[:status] = true
                    response_data[:result] = self.get_user_record({
                        :fields_to_filter => { :id => user_id },
                        :fields_to_select => "id, first_name, last_name, email"
                    })[:result]
                else
                    response_data[:error] = update_user_details[:error]
                end
            else
                raise "User already exists."
            end
        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end

    private
        # DOCU: Method to insert candidate for newly created users invited for interview
        # Triggered by: UserModel
        # Requires:  params - fields_to_filter
        # Optionals: params - fields_to_select
        # Returns: { status: true/false, result, error }
        # Last updated at: September 28, 2022
        # Owner: Adrian
        def self.get_user_record(params)
            response_data = { :status => false, :result => {}, :error => nil }

            begin
                params[:fields_to_select] ||= "*"

                select_user_query = ["SELECT #{ActiveRecord::Base.sanitize_sql(params[:fields_to_select])} FROM users
                #{ ' WHERE'if params[:fields_to_filter].present?}"]

                # Add the where clause depending on the fields_to_filter given
                if params[:fields_to_filter].present?
                    params[:fields_to_filter].each_with_index do |(field, value), index|
                        select_user_query[0] += "#{' AND' if index > 0} #{field} #{field.is_a?(Array) ? 'IN(?)' : '= ?'}"
                        select_user_query << value
                    end
                end

                user_details = query_record(select_user_query)

                response_data.merge!(user_details.present? ? { :status => true, :result => user_details } : { :error => "User not found" })
            rescue Exception => ex
                response_data[:error] = ex.message
            end

            return response_data
        end

        # DOCU: Method to user details dynamically
        # Triggered by: UserModel
        # Returns: { status: true/false, result: { user_details }, error }
        # Last updated at: Septemebr 28, 2022
        # Owner: Adrian
        def self.update_user_record(params)
            response_data = { :status => false, :result => {}, :error => nil }

            begin
                update_user_record_query = ["
                    UPDATE users SET #{params[:fields_to_update].map{ |field, value| "#{field}= '#{ActiveRecord::Base.sanitize_sql(value)}'" }.join(",")}
                    WHERE
                "]

                params[:fields_to_filter].each_with_index do |(field, value), index|
                    update_user_record_query[0] += " #{'AND' if index > 0} #{field} #{field.is_a?(Array) ? 'IN(?)' : '=?'}"
                    update_user_record_query    << value
                end

                response_data.merge!(update_record(update_user_record_query).present? ? { :status => true } : { :error => "Error in updating user record, please try again later." })
            rescue Exception => ex
                response_data[:error] = ex.message
            end

            return response_data
        end
end
