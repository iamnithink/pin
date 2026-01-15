require 'ostruct'

ActiveAdmin.register TournamentTheme do
  permit_params :name, :description, :preview_image_url, :color_scheme, :display_order, :is_active, :template_html

  menu priority: 8, label: "Tournament Themes", if: proc { current_user&.super_admin? }

  index do
    selectable_column
    id_column
    column :name
    column :display_order
    column :is_active
    column :created_at
    actions
  end

  filter :name
  filter :is_active
  filter :created_at

  scope :all
  scope :active

  form do |f|
    f.inputs "Theme Details" do
      f.input :name
      f.input :description
      f.input :preview_image_url, hint: "URL or path to preview image"
      f.input :color_scheme, hint: "JSON or string for theme colors (e.g., {\"primary\": \"#1E3A8A\", \"secondary\": \"#3B82F6\"})"
      f.input :display_order
      f.input :is_active
    end
    
    f.inputs "HTML Template" do
      f.input :template_html, as: :text, 
              hint: "HTML template with placeholders: {{TOURNAMENT_TITLE}}, {{VENUE_NAME}}, {{START_TIME}}, {{ENTRY_FEE}}, etc.",
              input_html: { rows: 20, style: 'font-family: monospace; font-size: 12px;' }
    end
    
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row :preview_image_url
      row :color_scheme
      row :display_order
      row :is_active
      row :created_at
      row :updated_at
    end

    panel "Theme Preview" do
      if tournament_theme.template_html.present?
        # Create a sample tournament for preview
        sample_tournament = OpenStruct.new(
          id: 999,
          title: "Sample Tournament",
          description: "This is a sample tournament preview",
          sport: OpenStruct.new(name: "Cricket"),
          venue: OpenStruct.new(name: "Sample Venue", full_address: "123 Main St, City, State 123456", google_maps_link: "https://www.google.com/maps?q=12.9716,77.5946"),
          start_time: 1.week.from_now,
          entry_fee: 500,
          max_players_per_team: 11,
          min_players_per_team: 5,
          pincode: "560001",
          rules_and_regulations: ActionText::Content.new("Sample rule 1\nSample rule 2"),
          created_by: OpenStruct.new(name: "Sample User"),
          organized_by: "Sample Sports Club",
          first_prize: 33000,
          second_prize: 22000,
          third_prize: 11000,
          prizes_json: { "fourth" => 5000, "fifth" => 3000 },
          tournament_theme: tournament_theme,
          venue_google_maps_link: "https://www.google.com/maps?q=12.9716,77.5946",
          venue_latitude: 12.9716,
          venue_longitude: 77.5946,
          latitude: 12.9716,
          longitude: 77.5946
        )
        
        div style: 'margin-top: 20px; border: 1px solid #ddd; padding: 20px; background: #f9f9f9;' do
          h4 "Live Preview (with sample data):"
          div style: 'margin-top: 10px;' do
            helpers.render_tournament_theme(sample_tournament)
          end
        end
      elsif tournament_theme.preview_image_url.present?
        div do
          image_tag tournament_theme.preview_image_url, style: 'max-width: 400px; max-height: 400px;'
        end
      else
        para "No preview available. Add template HTML to see preview."
      end
    end

    panel "Tournaments using this theme" do
      table_for tournament_theme.tournaments.limit(10) do
        column :title
        column :tournament_status
        column :created_at
        column :actions do |tournament|
          link_to "View", admin_tournament_path(tournament)
        end
      end
    end
  end

  # Use FriendlyId slugs in admin URLs
  controller do
    skip_authorization_check
    include TournamentThemeHelper
    
    # Block regular users from accessing this resource
    before_action :restrict_regular_users!
    
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      TournamentTheme.friendly.find(id_or_slug)
    end
    
    private
    
    def restrict_regular_users!
      if current_user.present? && current_user.regular_user?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
    end
  end
end
