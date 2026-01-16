ActiveAdmin.register Tournament do
  # Only eager load what's used in index view
  # Note: created_by is conditionally loaded in scoped_collection based on user role
  includes :sport, :cricket_match_type, :venue, :tournament_theme
  permit_params :title, :description, :sport_id, :cricket_match_type_id, :venue_id,
                :created_by_id, :start_time, :end_time,
                :max_players_per_team, :min_players_per_team, :entry_fee,
                :tournament_status, :pincode, :is_featured, :is_active,
                :tournament_theme_id, :rules_and_regulations,
                :first_prize, :second_prize, :third_prize, :prizes_json,
                :contact_phones, :teams_text, :organized_by,
                :venue_address, :venue_google_maps_link,
                :remove_image,
                team_ids: [], contact_phones: []
                # Note: :image is handled manually in create/update to avoid service_name errors

  # Show tournaments menu for all authenticated users
  menu priority: 4, label: "Tournaments", if: proc { current_user.present? }

  controller do
    skip_authorization_check
    
    # Note: Image parameter is now handled manually in create/update methods
    # to avoid service_name errors. No need for before_action cleaning.
    
    # Filter tournaments based on user role
    def scoped_collection
      return end_of_association_chain.none unless current_user.present?
      
      collection = if current_user.super_admin?
        # Super admin sees all tournaments
        end_of_association_chain
      elsif current_user.admin?
        # Admin sees all tournaments
        end_of_association_chain
      else
        # Regular users see only their own tournaments
        end_of_association_chain.where(created_by_id: current_user.id)
      end
      
      # Eager load associations for index view
      # For admins/super_admins, include created_by (shown in index)
      if current_user.admin? || current_user.super_admin?
        collection.includes(:sport, :cricket_match_type, :venue, :tournament_theme, :created_by)
      else
        # Regular users don't need created_by (not shown in their index)
        collection.includes(:sport, :cricket_match_type, :venue, :tournament_theme)
      end
    end
    
    # Auto-set created_by_id for regular users
    def build_resource
      resource = super
      if current_user.present? && current_user.regular_user? && resource.new_record?
        resource.created_by_id = current_user.id
      end
      resource
    end
    
    include TournamentThemeHelper
    
    # Ensure regular users can only access their own tournaments (with FriendlyId support)
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      resource = Tournament.friendly.find(id_or_slug)
      if current_user.present? && current_user.regular_user? && resource.created_by_id != current_user.id
        raise CanCan::AccessDenied.new("You can only access your own tournaments", :read, Tournament)
      end
      resource
    end

    def show
      # Eager load associations used in attributes_table and panels
      # Load teams and participants directly to avoid Bullet warnings
      # Preload image_attachment (not blob) - blob is loaded lazily when accessed
      # ActiveStorage handles blob access efficiently without eager loading
      @tournament = Tournament.includes(
        :sport, 
        :cricket_match_type, 
        :venue, 
        :created_by, 
        :tournament_theme,
        teams: [:sport, :captain],
        tournament_participants: [:user]
      )
      .preload(:image_attachment)
      .friendly.find(params[:id])
      super
    end

    def update
      # Ensure regular users can't change created_by_id
      if current_user.present? && current_user.regular_user? && params[:tournament] && params[:tournament][:created_by_id].present?
        params[:tournament][:created_by_id] = current_user.id
      end
      
      # Handle image deletion
      if params[:tournament].present? && 
         (params[:tournament][:remove_image] == '1' || 
          params[:tournament][:remove_image] == 'true' || 
          params[:tournament][:remove_image] == true)
        resource.image.purge if resource.image.attached?
        params[:tournament].delete(:remove_image)
        flash[:notice] = "Image has been removed." unless flash[:notice]
      end
      
      # Extract and handle image separately to avoid service_name errors
      # ActiveStorage::Blob doesn't accept service_name, so we handle image manually
      image_file = nil
      if params[:tournament].present? && params[:tournament][:image].present?
        image_param = params[:tournament][:image]
        
        # Check if it's a valid file upload object
        if image_param.is_a?(ActionDispatch::Http::UploadedFile) || 
           image_param.is_a?(Rack::Test::UploadedFile)
          # Direct file object - use it
          image_file = image_param
          params[:tournament].delete(:image)
        elsif image_param.is_a?(Hash)
          # Hash might contain file data - extract the actual file object
          # Don't pass the hash to ActiveStorage as it may contain service_name
          if image_param[:tempfile].present?
            # Extract just the file object, not the hash
            image_file = image_param[:tempfile]
            params[:tournament].delete(:image)
          elsif image_param['tempfile'].present?
            # Extract just the file object (string key)
            image_file = image_param['tempfile']
            params[:tournament].delete(:image)
          elsif image_param[:io].present?
            # Extract IO object
            image_file = image_param[:io]
            params[:tournament].delete(:image)
          elsif image_param['io'].present?
            # Extract IO object (string key)
            image_file = image_param['io']
            params[:tournament].delete(:image)
          else
            # Invalid hash without file data - remove it
            params[:tournament].delete(:image)
          end
        elsif image_param.is_a?(String)
          # String parameter - remove if blank, otherwise ignore (might be existing image URL)
          params[:tournament].delete(:image) if image_param.blank?
        end
      end
      
      process_tournament_params
      
      # Call parent update
      result = super
      
      # Attach image manually after update if we have a valid file
      if image_file.present? && resource.persisted? && !resource.errors.any?
        begin
          # Create a completely clean file to avoid any service_name metadata
          # Read file content and create a new clean Tempfile
          file_content = nil
          filename = 'image.jpg'
          content_type = 'image/jpeg'
          
          if image_file.is_a?(ActionDispatch::Http::UploadedFile) || 
             image_file.is_a?(Rack::Test::UploadedFile)
            image_file.rewind if image_file.respond_to?(:rewind)
            file_content = image_file.read
            filename = image_file.original_filename
            content_type = image_file.content_type
          elsif image_file.respond_to?(:read)
            image_file.rewind if image_file.respond_to?(:rewind)
            file_content = image_file.read
            filename = image_file.respond_to?(:original_filename) ? image_file.original_filename : 'image.jpg'
            content_type = image_file.respond_to?(:content_type) ? image_file.content_type : 'image/jpeg'
          end
          
          if file_content.present?
            # Create a completely clean Tempfile with no metadata
            clean_tempfile = Tempfile.new(['upload', File.extname(filename)])
            clean_tempfile.binmode
            clean_tempfile.write(file_content)
            clean_tempfile.rewind
            
            # Attach the clean file
            # Uses configured service: local in development, Cloudinary in production
            resource.image.attach(
              io: clean_tempfile,
              filename: filename,
              content_type: content_type
            )
          else
            # Fallback: attach directly if we can't read content
            resource.image.attach(image_file)
          end
          
          resource.save if resource.changed?
        rescue => e
          Rails.logger.error("Failed to attach image: #{e.message}")
          Rails.logger.error("Image file type: #{image_file.class}")
          Rails.logger.error(e.backtrace.join("\n"))
          flash[:error] = "Image could not be attached: #{e.message}" unless flash[:error]
        end
      end
      
      result
    end

    def create
      # Auto-set created_by_id for regular users
      if current_user.present? && current_user.regular_user? && params[:tournament]
        params[:tournament][:created_by_id] = current_user.id
      end
      
      # Extract and handle image separately to avoid service_name errors
      # ActiveStorage::Blob doesn't accept service_name, so we handle image manually
      image_file = nil
      if params[:tournament].present? && params[:tournament][:image].present?
        image_param = params[:tournament][:image]
        
        # Check if it's a valid file upload object
        if image_param.is_a?(ActionDispatch::Http::UploadedFile) || 
           image_param.is_a?(Rack::Test::UploadedFile)
          # Direct file object - use it
          image_file = image_param
          params[:tournament].delete(:image)
        elsif image_param.is_a?(Hash)
          # Hash might contain file data - extract the actual file object
          # Don't pass the hash to ActiveStorage as it may contain service_name
          if image_param[:tempfile].present?
            # Extract just the file object, not the hash
            image_file = image_param[:tempfile]
            params[:tournament].delete(:image)
          elsif image_param['tempfile'].present?
            # Extract just the file object (string key)
            image_file = image_param['tempfile']
            params[:tournament].delete(:image)
          elsif image_param[:io].present?
            # Extract IO object
            image_file = image_param[:io]
            params[:tournament].delete(:image)
          elsif image_param['io'].present?
            # Extract IO object (string key)
            image_file = image_param['io']
            params[:tournament].delete(:image)
          else
            # Invalid hash without file data - remove it
            params[:tournament].delete(:image)
          end
        elsif image_param.is_a?(String)
          # String parameter - remove if blank, otherwise ignore (might be existing image URL)
          params[:tournament].delete(:image) if image_param.blank?
        end
      end
      
      process_tournament_params
      
      # Call parent create
      result = super
      
      # Attach image manually after create if we have a valid file
      if image_file.present? && resource.persisted? && !resource.errors.any?
        begin
          # Create a completely clean file to avoid any service_name metadata
          # Read file content and create a new clean Tempfile
          file_content = nil
          filename = 'image.jpg'
          content_type = 'image/jpeg'
          
          if image_file.is_a?(ActionDispatch::Http::UploadedFile) || 
             image_file.is_a?(Rack::Test::UploadedFile)
            image_file.rewind if image_file.respond_to?(:rewind)
            file_content = image_file.read
            filename = image_file.original_filename
            content_type = image_file.content_type
          elsif image_file.respond_to?(:read)
            image_file.rewind if image_file.respond_to?(:rewind)
            file_content = image_file.read
            filename = image_file.respond_to?(:original_filename) ? image_file.original_filename : 'image.jpg'
            content_type = image_file.respond_to?(:content_type) ? image_file.content_type : 'image/jpeg'
          end
          
          if file_content.present?
            # Create a completely clean Tempfile with no metadata
            clean_tempfile = Tempfile.new(['upload', File.extname(filename)])
            clean_tempfile.binmode
            clean_tempfile.write(file_content)
            clean_tempfile.rewind
            
            # Attach the clean file
            # Uses configured service: local in development, Cloudinary in production
            resource.image.attach(
              io: clean_tempfile,
              filename: filename,
              content_type: content_type
            )
          else
            # Fallback: attach directly if we can't read content
            resource.image.attach(image_file)
          end
          
          resource.save if resource.changed?
        rescue => e
          Rails.logger.error("Failed to attach image: #{e.message}")
          Rails.logger.error("Image file type: #{image_file.class}")
          Rails.logger.error(e.backtrace.join("\n"))
          flash[:error] = "Image could not be attached: #{e.message}" unless flash[:error]
        end
      end
      
      result
    end

    private

    # Clean ActiveStorage parameters to prevent service_name errors
    # This is critical - ActiveStorage::Blob doesn't accept service_name attribute
    def clean_active_storage_params
      return unless params[:tournament].present?
      
      # Deep clean all parameters to remove service_name
      clean_hash(params[:tournament])
      
      # Specifically handle image parameter
      if params[:tournament][:image].present?
        image_param = params[:tournament][:image]
        
        # If it's a hash, clean it thoroughly
        if image_param.is_a?(Hash)
          # Remove ALL invalid ActiveStorage attributes
          %i[service_name service blob_id attachment_id].each do |key|
            image_param.delete(key)
            image_param.delete(key.to_s)
          end
          
          # Check if it's actually a valid file upload object
          is_valid_file = image_param.is_a?(ActionDispatch::Http::UploadedFile) ||
                         image_param.is_a?(Rack::Test::UploadedFile) ||
                         image_param.is_a?(ActionDispatch::Http::UploadedFile::Tempfile) ||
                         image_param[:tempfile].present? ||
                         image_param['tempfile'].present? ||
                         image_param[:io].present? ||
                         image_param['io'].present?
          
          if is_valid_file
            # It's a valid file - keep only the file object itself
            # Remove any metadata that might cause issues
            params[:tournament][:image] = image_param
          else
            # Not a valid file upload - remove entirely to prevent errors
            params[:tournament].delete(:image)
          end
        elsif image_param.is_a?(String)
          # String parameter - remove if blank
          params[:tournament].delete(:image) if image_param.blank?
        end
      end
    end
    
    # Recursively clean hash to remove service_name from all nested levels
    def clean_hash(hash)
      return unless hash.is_a?(Hash)
      
      hash.each do |key, value|
        # Remove service_name keys
        if key.to_s == 'service_name' || key.to_sym == :service_name
          hash.delete(key)
          next
        end
        
        # Recursively clean nested hashes
        if value.is_a?(Hash)
          clean_hash(value)
        elsif value.is_a?(Array)
          value.each { |item| clean_hash(item) if item.is_a?(Hash) }
        end
      end
    end

    def process_tournament_params
      return unless params[:tournament].present?
      
      # Image parameter should already be cleaned in create/update methods
      # This method focuses on other parameter processing
      
      # Parse prizes_json - handle both JSON string and key-value format
      if params[:tournament][:prizes_json].present?
        prizes_text = params[:tournament][:prizes_json].to_s.strip
        if prizes_text.present?
          begin
            # Try parsing as JSON first
            parsed = JSON.parse(prizes_text)
            # Ensure it's a hash - save as hash (even if empty, model expects Hash type)
            if parsed.is_a?(Hash)
              params[:tournament][:prizes_json] = parsed
            else
              params[:tournament][:prizes_json] = nil
            end
          rescue JSON::ParserError => e
            # If not JSON, try parsing as key-value pairs (e.g., "fourth: 5000, fifth: 3000")
            prizes_hash = {}
            prizes_text.split(',').each do |pair|
              if pair.include?(':')
                key, value = pair.split(':').map(&:strip)
                # Remove quotes from key if present
                key = key.gsub(/^["']|["']$/, '')
                prizes_hash[key] = value.to_f if key.present? && value.present?
              end
            end
            params[:tournament][:prizes_json] = prizes_hash.present? ? prizes_hash : {}
          end
        else
          params[:tournament][:prizes_json] = nil
        end
      else
        params[:tournament][:prizes_json] = nil
      end
      
      # Ensure prizes_json is a hash (model expects Hash type)
      # Convert nil to empty hash if needed
      if params[:tournament][:prizes_json].nil?
        params[:tournament][:prizes_json] = {}
      end

      # Process contact_phones - convert newline-separated text to Array (not JSON string!)
      if params[:tournament][:contact_phones].present? && params[:tournament][:contact_phones].is_a?(String)
        phones = params[:tournament][:contact_phones].split("\n").map(&:strip).reject(&:blank?)
        params[:tournament][:contact_phones] = phones.present? ? phones : nil
      elsif params[:tournament][:contact_phones].blank?
        params[:tournament][:contact_phones] = nil
      end

      # Process teams_text - just store as text
      params[:tournament][:teams_text] = params[:tournament][:teams_text].presence
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :sport
    column :cricket_match_type
    column :venue
    column :tournament_status
    column :tournament_theme
    column :start_time
    column :is_featured
    column :view_count
    column :created_at
    if current_user.present? && (current_user.admin? || current_user.super_admin?)
      column :created_by
    end
    actions
  end

  filter :title
  filter :sport
  filter :tournament_status
  filter :pincode
  filter :is_featured
  filter :start_time
  filter :created_at
  filter :tournament_theme

  scope :all, default: true
  scope :draft
  scope :published
  scope :cancelled
  scope :completed
  scope :featured

  form do |f|
    f.inputs "Tournament Details" do
      f.input :title
      f.input :description
      f.input :sport
      f.input :cricket_match_type, as: :select, collection: CricketMatchType.active.map { |t| [t.display_name, t.id] }
      f.input :organized_by, hint: "Organizer name (e.g., 'Sports Club', 'John Doe', 'Tournament Committee')"
      if current_user.super_admin? || current_user.admin?
        f.input :created_by, hint: "User who created this tournament (for internal tracking)"
      else
        # Regular users can't change created_by - it's auto-set to them
        f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
      end
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :max_players_per_team
      f.input :min_players_per_team
      f.input :entry_fee
      f.input :tournament_status, as: :select, collection: %w[draft published cancelled completed live]
      f.input :pincode
    end

    f.inputs "Venue (Google Maps)" do
      f.input :venue_address, as: :text, hint: "Full address from Google Maps", input_html: { rows: 2 }
      f.input :venue_google_maps_link, hint: "Google Maps link (optional)"
      f.input :venue, as: :select, 
              collection: Venue.active.order(:name).map { |v| [v.name, v.id] },
              hint: "Legacy venue (optional - use Google Maps fields above instead)"
    end

    f.inputs "Contact Information" do
      contact_phones_value = if f.object.contact_phones.present?
        # Handle both Array (from serialize) and String (from form)
        phones = if f.object.contact_phones.is_a?(Array)
          f.object.contact_phones
        elsif f.object.contact_phones.is_a?(String)
          begin
            JSON.parse(f.object.contact_phones)
          rescue JSON::ParserError
            f.object.contact_phones.split("\n").map(&:strip).reject(&:blank?)
          end
        else
          []
        end
        phones.is_a?(Array) ? phones.join("\n") : ""
      else
        ""
      end
      f.input :contact_phones, as: :text,
              hint: "Enter phone numbers, one per line (e.g., 9876543210, 9876543211)",
              input_html: { 
                rows: 3, 
                placeholder: "9876543210\n9876543211\n9876543212",
                value: contact_phones_value
              }
    end

    f.inputs "Prizes" do
      f.input :first_prize, hint: "First prize amount (e.g., 33000)"
      f.input :second_prize, hint: "Second prize amount (e.g., 22000)"
      f.input :third_prize, hint: "Third prize amount (optional)"
      # Get current prizes_json value for form display
      prizes_json_value = ""
      if f.object.prizes_json.present?
        if f.object.prizes_json.is_a?(String)
          # Already a string, use as is
          prizes_json_value = f.object.prizes_json
        elsif f.object.prizes_json.is_a?(Hash)
          # Convert hash to JSON string for display
          prizes_json_value = f.object.prizes_json.to_json
        end
      end
      
      f.input :prizes_json, as: :text, 
              hint: "Additional prizes as JSON. Format: {\"fourth\": 5000, \"fifth\": 3000}. Example: {\"fourth\": 5000, \"fifth\": 3000, \"sixth\": 2000}",
              input_html: { 
                rows: 5, 
                style: 'font-family: monospace; font-size: 13px;',
                placeholder: '{"fourth": 5000, "fifth": 3000}',
                value: prizes_json_value
              }
    end

    f.inputs "Tournament Details" do
      f.input :is_featured
      f.input :is_active
    end

    f.inputs "Image or Theme" do
      # Image upload section
      if f.object.image.attached?
        div style: 'margin-bottom: 15px; padding: 10px; background: #f5f5f5; border-radius: 4px;' do
          div style: 'margin-bottom: 10px;' do
            image_tag(url_for(f.object.image), style: 'max-width: 200px; max-height: 200px; display: block; border: 1px solid #ddd; border-radius: 4px;')
          end
          para "<strong>Current Image:</strong> #{f.object.image.filename}".html_safe, style: 'margin: 5px 0;'
          para "<small>Upload a new file to replace it, or check 'Remove Image' below to delete it.</small>".html_safe, style: 'margin: 5px 0; color: #666;'
        end
      end
      
      f.input :image, as: :file, 
              hint: f.object.image.attached? ? 
                "Upload a new image to replace the current one" : 
                "Upload tournament image (JPG, PNG, GIF, WebP - Max 10MB). Images are stored locally in development, on Cloudinary in production.",
              input_html: { accept: 'image/jpeg,image/png,image/gif,image/webp' }
      
      # Image delete checkbox
      if f.object.image.attached?
        f.input :remove_image, as: :boolean, 
                label: "Remove Image",
                hint: "Check this box to delete the current image. You can upload a new one or select a theme instead.",
                wrapper_html: { style: 'margin-top: 10px;' }
      end
      
      # Divider
      hr style: 'margin: 20px 0; border: none; border-top: 1px solid #ddd;'
      
      # Theme selection section
      if f.object.tournament_theme.present?
        div style: 'margin-bottom: 15px; padding: 10px; background: #f0f8ff; border-radius: 4px; border-left: 4px solid #4a90e2;' do
          h4 style: 'margin: 0 0 5px 0;' do
            "Current Theme: #{f.object.tournament_theme.name}"
          end
          if f.object.tournament_theme.description.present?
            para f.object.tournament_theme.description, style: 'margin: 5px 0; color: #555;'
          end
          if f.object.tournament_theme.preview_image_url.present?
            div style: 'margin-top: 10px;' do
              image_tag(f.object.tournament_theme.preview_image_url, style: 'max-width: 200px; max-height: 200px; border: 1px solid #ddd; border-radius: 4px;')
            end
          end
        end
      end
      
      f.input :tournament_theme, as: :select, 
              collection: [['None', '']] + TournamentTheme.active.ordered.map { |t| [t.name, t.id] },
              include_blank: false,
              hint: "Select a theme if not uploading an image. Either image or theme is required for published tournaments."
    end

    f.inputs "Rules & Regulations" do
      f.input :rules_and_regulations, as: :rich_text_area
    end

    f.inputs "Teams" do
      f.input :teams_text, as: :text,
              hint: "Enter team names, one per line (e.g., Team A, Team B, Team C). Teams will be displayed as a numbered list.",
              input_html: { 
                rows: 5,
                placeholder: "Team A\nTeam B\nTeam C"
              }
      f.input :teams, as: :select, 
              collection: Team.active.includes(:sport).map { |t| ["#{t.name} (#{t.sport.name})#{' [Default]' if t.is_default?}", t.id] },
              input_html: { multiple: true, class: 'chosen-select' },
              hint: "Legacy: Select existing teams (optional - use Teams Text field above instead)" if current_user.super_admin?
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :sport
      row :cricket_match_type
      row :venue_address do |tournament|
        tournament.venue_address.presence || (tournament.venue&.full_address) || '-'
      end
      row :venue_google_maps_link do |tournament|
        if tournament.venue_google_maps_link.present?
          link_to tournament.venue_google_maps_link, tournament.venue_google_maps_link, target: '_blank'
        elsif tournament.venue&.google_maps_link.present?
          link_to tournament.venue.google_maps_link, tournament.venue.google_maps_link, target: '_blank'
        else
          '-'
        end
      end
      row :venue do |tournament|
        tournament.venue ? link_to(tournament.venue.name, admin_venue_path(tournament.venue)) : '-'
      end
      row :organized_by do |tournament|
        tournament.organized_by.presence || '-'
      end
      row :created_by
      row :contact_phones do |tournament|
        if tournament.contact_phones.present?
          phones = tournament.contact_phones.is_a?(String) ? JSON.parse(tournament.contact_phones) : tournament.contact_phones
          if phones.is_a?(Array)
            phones.map { |phone| link_to(phone, "tel:#{phone}") }.join(', ').html_safe
          else
            phones.to_s
          end
        else
          '-'
        end
      end
      row :start_time
      row :end_time
      row :tournament_status
      row :pincode
      row :entry_fee
      row :first_prize do |tournament|
        tournament.first_prize ? "₹#{tournament.first_prize}" : '-'
      end
      row :second_prize do |tournament|
        tournament.second_prize ? "₹#{tournament.second_prize}" : '-'
      end
      row :third_prize do |tournament|
        tournament.third_prize ? "₹#{tournament.third_prize}" : '-'
      end
      row :prizes_json do |tournament|
        if tournament.prizes_json.present?
          prizes_data = tournament.prizes_json
          # Handle both string and hash
          if prizes_data.is_a?(String)
            begin
              prizes_data = JSON.parse(prizes_data)
            rescue JSON::ParserError
              prizes_data = {}
            end
          end
          if prizes_data.is_a?(Hash) && prizes_data.any?
            prizes_data.map { |level, amount| "#{level.to_s.humanize}: ₹#{amount.to_i}" }.join(', ')
          else
            '-'
          end
        else
          '-'
        end
      end
      row :view_count
      row :join_count
      row :is_featured
      row :is_active
      row :created_at
      row :updated_at
    end

    # Show both image and theme if they exist
    if tournament.image.attached? || tournament.tournament_theme.present?
      # Image Panel
      if tournament.image.attached?
        panel "Tournament Image" do
          div style: 'padding: 15px; background: #f5f5f5; border-radius: 4px;' do
            div style: 'margin: 15px 0;' do
              image_tag url_for(tournament.image), style: 'max-width: 100%; max-height: 500px; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);'
            end
          end
        end
      end

      # Theme Panel
      if tournament.tournament_theme.present?
        panel "Tournament Theme" do
          div style: 'padding: 15px; background: #f0f8ff; border-radius: 4px; border-left: 4px solid #4a90e2;' do
            h3 style: 'margin-top: 0; color: #4a90e2;' do
              tournament.tournament_theme.name
            end
            if tournament.tournament_theme.description.present?
              para tournament.tournament_theme.description, style: 'margin: 10px 0; color: #555;'
            end
            if tournament.tournament_theme.preview_image_url.present?
              div style: 'margin: 15px 0;' do
                image_tag tournament.tournament_theme.preview_image_url, 
                          style: 'max-width: 100%; max-height: 500px; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);',
                          onerror: "this.style.display='none'"
              end
            end
            # Render the theme template
            if tournament.tournament_theme.template_html.present?
              div style: 'margin-top: 20px; padding: 20px; background: white; border: 1px solid #ddd; border-radius: 4px;' do
                h4 "Theme Preview:"
                div do
                  # Render the theme template HTML
                  theme_html = render_tournament_theme(tournament)
                  if theme_html.present?
                    raw theme_html
                  else
                    para "Unable to render theme preview. Please check theme template HTML.", style: 'color: #d32f2f;'
                  end
                end
              end
            end
          end
        end
      end
    else
      panel "Image or Theme" do
        div style: 'padding: 15px; background: #fff3cd; border-radius: 4px; border-left: 4px solid #ffc107;' do
          para "<strong>No image or theme selected.</strong> Either upload an image or select a theme for this tournament.".html_safe, style: 'margin: 0; color: #856404;'
        end
      end
    end

    panel "Rules & Regulations" do
      div do
        tournament.rules_and_regulations if tournament.rules_and_regulations.present?
      end
    end

    panel "Teams" do
      if tournament.teams_text.present?
        div do
          h4 "Teams:"
          teams_list = tournament.teams_text.split("\n").reject(&:blank?).map(&:strip)
          if teams_list.any?
            ol style: 'padding-left: 20px; margin: 10px 0;' do
              teams_list.each_with_index do |team, index|
                li style: 'margin: 5px 0; padding: 3px 0;' do
                  "#{index + 1}. #{team}"
                end
              end
            end
          else
            para "No teams specified"
          end
        end
      end
      
      if tournament.teams.any?
        div style: 'margin-top: 20px;' do
          h4 "Teams (Legacy Association):"
          table_for tournament.teams do
            column :name
            column :sport do |team|
              team.sport.name
            end
            column :captain do |team|
              team.captain.name
            end
            column :member_count
            column :is_default do |team|
              team.is_default? ? "Yes (Admin)" : "No (User)"
            end
            column :is_active
            column :actions do |team|
              link_to "View", admin_team_path(team)
            end
          end
        end
      end
    end

    panel "Participants" do
      # Participants are already loaded via includes in show action
      table_for tournament.tournament_participants do
        column :user do |tp|
          tp.user.name
        end
        column :phone do |tp|
          tp.user.phone
        end
        column :status
        column :role
        column :created_at
      end
    end
  end

  member_action :publish, method: :put do
    resource.publish!
    redirect_to resource_path, notice: "Tournament published!"
  end

  member_action :unpublish, method: :put do
    resource.unpublish!
    redirect_to resource_path, notice: "Tournament unpublished!"
  end

  action_item :publish, only: :show, if: proc { tournament.tournament_status == 'draft' } do
    link_to "Publish Tournament", publish_admin_tournament_path(tournament), method: :put
  end

  action_item :unpublish, only: :show, if: proc { tournament.tournament_status == 'published' } do
    link_to "Unpublish Tournament", unpublish_admin_tournament_path(tournament), method: :put
  end
end
