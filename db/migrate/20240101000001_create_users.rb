class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :phone, null: false, default: ""
      t.string :name
      t.string :encrypted_password, null: false, default: ""
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.string :otp_secret
      t.datetime :otp_sent_at
      t.boolean :phone_verified, default: false
      t.string :pincode
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :address
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
    add_index :users, [:provider, :uid]
    add_index :users, :pincode
    add_index :users, [:latitude, :longitude]
    add_index :users, :reset_password_token, unique: true
  end
end

