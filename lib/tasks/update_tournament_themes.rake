namespace :tournament_themes do
  desc "Update tournament theme templates with latest structure"
  task update: :environment do
    puts "Updating tournament theme templates..."
    
    themes_data = [
      { 
        name: 'Classic Blue', 
        template_html: TournamentThemeTemplates::CLASSIC_BLUE
      },
      { 
        name: 'Fire Red', 
        template_html: TournamentThemeTemplates::FIRE_RED
      },
      { 
        name: 'Forest Green', 
        template_html: TournamentThemeTemplates::FOREST_GREEN
      }
    ]
    
    themes_data.each do |attrs|
      theme = TournamentTheme.find_by(name: attrs[:name])
      if theme
        puts "Updating #{theme.name}..."
        theme.update!(template_html: attrs[:template_html])
        puts "✓ #{theme.name} updated successfully"
      else
        puts "⚠ Theme '#{attrs[:name]}' not found"
      end
    end
    
    puts "\nAll tournament themes updated!"
  end
end
