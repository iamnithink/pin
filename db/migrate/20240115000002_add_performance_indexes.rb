# Add performance indexes for frequently queried fields
class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Composite index for tournament queries (status + active + start_time)
    unless index_exists?(:tournaments, [:tournament_status, :is_active, :start_time])
      add_index :tournaments, [:tournament_status, :is_active, :start_time], 
                name: 'index_tournaments_on_status_active_start_time'
    end

    # Index for tournament_theme_id (used in filters and joins)
    unless index_exists?(:tournaments, :tournament_theme_id)
      add_index :tournaments, :tournament_theme_id
    end

    # Index for sport_id + tournament_status (common filter combination)
    unless index_exists?(:tournaments, [:sport_id, :tournament_status])
      add_index :tournaments, [:sport_id, :tournament_status], 
                name: 'index_tournaments_on_sport_status'
    end

    # Index for active_storage_blobs service_name (for faster lookups)
    unless index_exists?(:active_storage_blobs, :service_name)
      add_index :active_storage_blobs, :service_name
    end

    # Index for active_storage_variant_records blob_id (for faster variant lookups)
    unless index_exists?(:active_storage_variant_records, :blob_id)
      add_index :active_storage_variant_records, :blob_id
    end
  end
end
