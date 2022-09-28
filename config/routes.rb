Rails.application.routes.draw do
	# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

	# Defines the root path route ("/")

	scope "accounts" do
		get "register_page"  => "accounts#register_page"
		get "login_page"     => "accounts#login_page"
		get "home_page"      => "accounts#home_page"
		get "edit_page" 	 => "accounts#edit_page"

		post "register"       => "accounts#register"
		post "update_account" => "accounts#update_user_details"
		post "login"          => "accounts#login"
	end

	get "logout" => "accounts#logout"

	root "accounts#register_page"
end
