# Create active_storage_variant_records table
# This table is required for ActiveStorage variant tracking in Rails 7.2
class CreateActiveStorageVariantRecords < ActiveRecord::Migration[7.2]
  def change
    # Check if table already exists
    unless table_exists?(:active_storage_variant_records)
      create_table :active_storage_variant_records do |t|
        t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }
        t.string :variation_digest, null: false

        t.index [:blob_id, :variation_digest], unique: true, name: "index_active_storage_variant_records_uniqueness"
      end
    end
  end
end
