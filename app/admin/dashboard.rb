ActiveAdmin.register_page "Dashboard" do
  # Show dashboard menu for all authenticated users
  menu priority: 1, label: proc { "Dashboard" }, if: proc { current_user.present? }

  controller do
    skip_authorization_check
  end

  content title: proc { 
    if current_user.super_admin? || current_user.admin?
      "PIN Admin Dashboard"
    else
      "My Dashboard"
    end
  } do
    # Statistics Section - Top
    if current_user.super_admin? || current_user.admin?
      # Admin/Super Admin: Show system-wide statistics with modern card design
      panel "System Statistics", class: "stats-panel" do
        div class: "stats-grid" do
          div class: "stat-card-modern" do
            div class: "stat-icon" do "👥" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Users" end
              div class: "stat-value" do User.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "🏆" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Tournaments" end
              div class: "stat-value" do Tournament.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "✅" end
            div class: "stat-content" do
              div class: "stat-label" do "Published" end
              div class: "stat-value" do Tournament.published.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "📝" end
            div class: "stat-content" do
              div class: "stat-label" do "Draft" end
              div class: "stat-value" do Tournament.draft.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "📍" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Venues" end
              div class: "stat-value" do Venue.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "👥" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Teams" end
              div class: "stat-value" do "#{Team.count}" end
              div class: "stat-sublabel" do "(Default: #{Team.default_teams.count}, User: #{Team.user_teams.count})" end
            end
          end
          if current_user.super_admin?
            div class: "stat-card-modern" do
              div class: "stat-icon" do "👑" end
              div class: "stat-content" do
                div class: "stat-label" do "Admins" end
                div class: "stat-value" do User.admins.count end
              end
            end
            div class: "stat-card-modern" do
              div class: "stat-icon" do "👤" end
              div class: "stat-content" do
                div class: "stat-label" do "Regular Users" end
                div class: "stat-value" do User.users.count end
              end
            end
          end
        end
      end
    else
      # Regular User: Show their own statistics with modern card design
      panel "My Statistics", class: "stats-panel" do
        user_tournaments = current_user.created_tournaments
        div class: "stats-grid" do
          div class: "stat-card-modern" do
            div class: "stat-icon" do "🏆" end
            div class: "stat-content" do
              div class: "stat-label" do "My Tournaments" end
              div class: "stat-value" do user_tournaments.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "✅" end
            div class: "stat-content" do
              div class: "stat-label" do "Published" end
              div class: "stat-value" do user_tournaments.published.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "📝" end
            div class: "stat-content" do
              div class: "stat-label" do "Draft" end
              div class: "stat-value" do user_tournaments.draft.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "🏁" end
            div class: "stat-content" do
              div class: "stat-label" do "Completed" end
              div class: "stat-value" do user_tournaments.completed.count end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "👁️" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Views" end
              div class: "stat-value" do user_tournaments.sum(:view_count) || 0 end
            end
          end
          div class: "stat-card-modern" do
            div class: "stat-icon" do "❤️" end
            div class: "stat-content" do
              div class: "stat-label" do "Total Likes" end
              div class: "stat-value" do user_tournaments.sum(:likes_count) || 0 end
            end
          end
        end
      end
    end

    # Tournaments Section - Below Statistics
    if current_user.super_admin? || current_user.admin?
      # Admin/Super Admin: Show all tournaments
      panel "Recent Tournaments", class: "tournaments-panel" do
        table_for Tournament.includes(:sport, :created_by, :tournament_theme).order('created_at DESC').limit(10), class: "dashboard-table" do
          column :title
          column :sport
          column :tournament_status
          column :created_by do |tournament|
            tournament.created_by&.name || '-'
          end
          column :start_time
          column :created_at
          column :actions do |tournament|
            link_to "View", admin_tournament_path(tournament)
          end
        end
      end
    else
      # Regular User: Show only their tournaments
      panel "My Recent Tournaments", class: "tournaments-panel" do
        user_tournaments = current_user.created_tournaments.includes(:sport).order('created_at DESC').limit(10)
        if user_tournaments.any?
          table_for user_tournaments, class: "dashboard-table" do
            column :title
            column :sport
            column :tournament_status
            column :start_time
            column :created_at
            column :actions do |tournament|
              link_to "View", admin_tournament_path(tournament)
            end
          end
        else
          para "You haven't created any tournaments yet."
          para do
            link_to "Create Your First Tournament", new_admin_tournament_path, class: "button"
          end
        end
      end
    end
    
    # Add custom CSS for modern dashboard cards
    style do
      <<-CSS
        .stats-panel {
          margin-bottom: 20px;
        }

        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 15px;
          margin-top: 15px;
        }

        .stat-card-modern {
          background: linear-gradient(
            135deg,
            #1e40af 0%,
            #3b82f6 50%,
            #60a5fa 100%
          );
          border-radius: 12px;
          padding: 20px;
          display: flex;
          align-items: center;
          gap: 15px;
          box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
          transition: transform 0.3s ease, box-shadow 0.3s ease;
          color: white;
        }

        .stat-card-modern:hover {
          transform: translateY(-5px);
          box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .stat-card-modern:nth-child(2) {
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          box-shadow: 0 4px 15px rgba(245, 87, 108, 0.3);
        }

        .stat-card-modern:nth-child(2):hover {
          box-shadow: 0 6px 20px rgba(245, 87, 108, 0.4);
        }

        .stat-card-modern:nth-child(3) {
          background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
          box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
        }

        .stat-card-modern:nth-child(3):hover {
          box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4);
        }

        .stat-card-modern:nth-child(4) {
          background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
          box-shadow: 0 4px 15px rgba(67, 233, 123, 0.3);
        }

        .stat-card-modern:nth-child(4):hover {
          box-shadow: 0 6px 20px rgba(67, 233, 123, 0.4);
        }

        .stat-card-modern:nth-child(5) {
          background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
          box-shadow: 0 4px 15px rgba(250, 112, 154, 0.3);
        }

        .stat-card-modern:nth-child(5):hover {
          box-shadow: 0 6px 20px rgba(250, 112, 154, 0.4);
        }

        .stat-card-modern:nth-child(6) {
          background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
          box-shadow: 0 4px 15px rgba(48, 207, 208, 0.3);
        }

        .stat-card-modern:nth-child(6):hover {
          box-shadow: 0 6px 20px rgba(48, 207, 208, 0.4);
        }

        .stat-icon {
          font-size: 2.5rem;
          line-height: 1;
        }

        .stat-content {
          flex: 1;
        }

        .stat-label {
          font-size: 0.85rem;
          opacity: 0.9;
          margin-bottom: 5px;
          font-weight: 500;
        }

        .stat-value {
          font-size: 1.8rem;
          font-weight: bold;
          line-height: 1;
        }

        .stat-sublabel {
          font-size: 0.75rem;
          opacity: 0.8;
          margin-top: 3px;
        }

        .tournaments-panel {
          margin-top: 30px;
        }

        .dashboard-table {
          width: 100%;
          overflow-x: auto;
        }

        .dashboard-table table {
          width: 100%;
          min-width: 600px;
        }

        @media (max-width: 1024px) {
          .stats-grid {
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
          }

          .stat-card-modern {
            padding: 18px;
            gap: 12px;
          }

          .stat-icon {
            font-size: 2.2rem;
          }

          .stat-value {
            font-size: 1.6rem;
          }
        }

        @media (max-width: 768px) {
          .stats-grid {
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
          }

          .stat-card-modern {
            padding: 15px;
            gap: 10px;
          }

          .stat-icon {
            font-size: 2rem;
          }

          .stat-value {
            font-size: 1.5rem;
          }

          .stat-label {
            font-size: 0.8rem;
          }

          .tournaments-panel {
            margin-top: 20px;
          }

          .dashboard-table {
            overflow-x: scroll;
            -webkit-overflow-scrolling: touch;
          }

          .dashboard-table table {
            font-size: 0.9rem;
          }
        }

        @media (max-width: 480px) {
          .stats-grid {
            grid-template-columns: 1fr;
            gap: 10px;
          }

          .stat-card-modern {
            padding: 12px;
            gap: 8px;
          }

          .stat-icon {
            font-size: 1.8rem;
          }

          .stat-value {
            font-size: 1.3rem;
          }

          .stat-label {
            font-size: 0.75rem;
          }
        }
      CSS
    end
  end
end

