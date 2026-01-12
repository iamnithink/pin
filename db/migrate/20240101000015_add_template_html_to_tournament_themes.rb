class AddTemplateHtmlToTournamentThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :tournament_themes, :template_html, :text
  end
end
