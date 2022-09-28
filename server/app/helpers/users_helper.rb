module UsersHelper
    # DOCU: Validate new user information
    # Triggered by: multiple models
    # Requires: params
    # Returns: { status, result{params}, error }
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def validate_new_user_info(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            validations = {
                :name     => { :regex => /[@%^&!"\\\*\.,\-\:?\/\'=`{}()+_\]\|\[\><~;$#0-9]/, :error => "Special Characters are not allowed on name" },
                :password => { :regex => /^(?=.*?[A-Z])(?=.*?[0-9]).{0,}$/, :error => "Password must have an uppercase letter and a number" },
                :email    => { :regex => URI::MailTo::EMAIL_REGEXP, :error => "Please enter a valid email" }
            }

            params.each do |key, value|
                validation_key  = [:first_name, :last_name].include?(key) ? :name : key

                if validation_key === :password && params[:confirm_password].present?
                    response_data[:result][:password] = "Passwords do not match" if params[:password] != params[:confirm_password]
                end

                # Validate the email address, firrst step is check the email pattern
                if validation_key === :email
                    response_data[:result][:email] = "User already Exists" if User.get_user_record({ :fields_to_filter => { :email => value.downcase } })[:status]
                end

                next if validations[validation_key].nil?

                validation_comparison = validations[validation_key][:regex] =~ value

                response_data[:result][validation_key] = validations[validation_key][:error] if validation_key === :name ? !validation_comparison.nil? : validation_comparison.nil?
            end

            response_data[:status] = response_data[:result].empty?
        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end

    # DOCU: Set user session
    # Triggered by: UsersController
    # Requires: user_data - id, first_name, last_name, email
    # Last updated at: September 28, 2022
    # Owner: Adrian
    def set_user_session(user_data)
        session[:user_id]    = user_data[:id]
        session[:first_name] = user_data[:first_name]
        session[:last_name]  = user_data[:last_name]
        session[:email]      = user_data[:email]
    end
end