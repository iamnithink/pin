# Add service_name column to active_storage_blobs
# This is required for Rails 6.1+ ActiveStorage when using multiple storage services
# The service_name column stores which storage service (local, cloudinary, etc.) is used for each blob
class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[7.2]
  def up
    # Check if column already exists
    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string, null: false, default: 'local'
      
      # Update existing blobs to use 'local' service
      execute "UPDATE active_storage_blobs SET service_name = 'local' WHERE service_name IS NULL"
    end
  end

  def down
    # Remove column if it exists
    if column_exists?(:active_storage_blobs, :service_name)
      remove_column :active_storage_blobs, :service_name
    end
  end
end
