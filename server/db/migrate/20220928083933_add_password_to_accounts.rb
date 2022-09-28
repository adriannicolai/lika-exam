class AddPasswordToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password, :string, limit: 255, after: :email
  end
end
