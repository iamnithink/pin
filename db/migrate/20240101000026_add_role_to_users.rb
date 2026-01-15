class AddRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role, :string, default: 'user', null: false
    add_index :users, :role
    
    # Set existing users to 'user' role (already default, but explicit for clarity)
    User.update_all(role: 'user') if User.table_exists? && User.any?
  end
end
