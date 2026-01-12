ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { "Dashboard" }

  content title: proc { "PIN Admin Dashboard" } do
    columns do
      column do
        panel "Recent Tournaments" do
          table_for Tournament.includes(:sport).order('created_at DESC').limit(10) do
            column :title
            column :sport
            column :tournament_status
            column :start_time
            column :created_at
          end
        end
      end

      column do
        panel "Statistics" do
          div do
            h3 "Total Users: #{User.count}"
          end
          div do
            h3 "Total Tournaments: #{Tournament.count}"
          end
          div do
            h3 "Published Tournaments: #{Tournament.published.count}"
          end
          div do
            h3 "Total Venues: #{Venue.count}"
          end
          div do
            h3 "Total Teams: #{Team.count} (Default: #{Team.default_teams.count}, User: #{Team.user_teams.count})"
          end
        end
      end
    end
  end
end

