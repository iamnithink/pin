ActiveAdmin.register Tournament do
  # Only eager load what's used in index view
  includes :sport, :cricket_match_type, :venue, :tournament_theme
  permit_params :title, :description, :sport_id, :cricket_match_type_id, :venue_id,
                :created_by_id, :start_time, :end_time,
                :max_players_per_team, :min_players_per_team, :entry_fee,
                :tournament_status, :pincode, :is_featured, :is_active,
                :tournament_theme_id, :rules_and_regulations, :image,
                :first_prize, :second_prize, :third_prize, :prizes_json,
                :contact_phones, :teams_text, :organized_by,
                :venue_name, :venue_address, :venue_latitude, :venue_longitude, :venue_google_maps_link,
                team_ids: [], contact_phones: []

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

  scope :all
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
      f.input :created_by, hint: "User who created this tournament (for internal tracking)"
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :max_players_per_team
      f.input :min_players_per_team
      f.input :entry_fee
      f.input :tournament_status, as: :select, collection: %w[draft published cancelled completed live]
      f.input :pincode
    end

    f.inputs "Venue (Google Maps)" do
      f.input :venue_name, hint: "Venue name from Google Maps"
      f.input :venue_address, as: :text, hint: "Full address from Google Maps", input_html: { rows: 2 }
      f.input :venue_latitude, hint: "Latitude from Google Maps"
      f.input :venue_longitude, hint: "Longitude from Google Maps"
      f.input :venue_google_maps_link, hint: "Google Maps link (optional)"
      f.input :venue, hint: "Legacy venue (optional - use Google Maps fields above instead)"
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
      f.input :image, as: :file, hint: f.object.image.attached? ? image_tag(f.object.image, style: 'max-width: 200px; max-height: 200px;') : "Upload tournament image"
      f.input :tournament_theme, as: :select, collection: TournamentTheme.active.ordered.map { |t| [t.name, t.id] },
              hint: "Select a theme if not uploading an image. Either image or theme is required."
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
              hint: "Legacy: Select existing teams (optional - use Teams Text field above instead)"
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
      row :venue_name do |tournament|
        tournament.venue_name.presence || (tournament.venue&.name)
      end
      row :venue_address do |tournament|
        tournament.venue_address.presence || (tournament.venue&.full_address)
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

    panel "Image or Theme" do
      if tournament.image.attached?
        div do
          image_tag tournament.image, style: 'max-width: 400px; max-height: 400px;'
        end
      elsif tournament.tournament_theme.present?
        div do
          h3 tournament.tournament_theme.name
          para tournament.tournament_theme.description if tournament.tournament_theme.description.present?
          if tournament.tournament_theme.preview_image_url.present?
            image_tag tournament.tournament_theme.preview_image_url, style: 'max-width: 400px; max-height: 400px;'
          end
          # Render the theme template
          if tournament.tournament_theme.template_html.present?
            div style: 'margin-top: 20px; border: 1px solid #ddd; padding: 20px;' do
              helpers.render_tournament_theme(tournament)
            end
          end
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

  # Eager load associations for show action and handle FriendlyId slugs
  controller do
    include TournamentThemeHelper
    
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      Tournament.friendly.find(id_or_slug)
    end

    def show
      # Eager load associations used in attributes_table and panels
      # Load teams and participants directly to avoid Bullet warnings
      @tournament = Tournament.includes(
        :sport, 
        :cricket_match_type, 
        :venue, 
        :created_by, 
        :tournament_theme,
        teams: [:sport, :captain],
        tournament_participants: [:user]
      ).friendly.find(params[:id])
      super
    end

    def update
      process_tournament_params
      super
    end

    def create
      process_tournament_params
      super
    end

    private

    def process_tournament_params
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
end
