require 'cgi'

module TournamentThemeHelper
  def render_tournament_theme(tournament)
    return nil unless tournament.tournament_theme.present?
    
    theme = tournament.tournament_theme
    return nil unless theme.template_html.present?
    
    # Replace placeholders with tournament data
    html = theme.template_html.dup
    
    # Replace theme ID for unique element IDs
    html.gsub!('{{THEME_ID}}', theme.id.to_s)
    
    # Replace tournament data placeholders
    html.gsub!('{{TOURNAMENT_TITLE}}', tournament.title || 'Tournament')
    html.gsub!('{{TOURNAMENT_DESCRIPTION}}', tournament.description || '')
    html.gsub!('{{SPORT_NAME}}', tournament.sport.name || 'Sport')
    # Use venue_address if available, otherwise fall back to venue association
    venue_address = tournament.respond_to?(:venue_address) && tournament.venue_address.present? ? tournament.venue_address : (tournament.venue&.full_address || '')
    html.gsub!('{{VENUE_ADDRESS}}', venue_address)
    html.gsub!('{{START_TIME}}', tournament.start_time ? tournament.start_time.strftime('%B %d, %Y') : 'TBD')
    html.gsub!('{{START_TIME_FULL}}', tournament.start_time ? tournament.start_time.strftime('%B %d, %Y at %I:%M %p') : 'TBD')
    html.gsub!('{{ENTRY_FEE}}', tournament.entry_fee ? "₹#{tournament.entry_fee}" : 'Free')
    html.gsub!('{{MAX_PLAYERS}}', tournament.max_players_per_team ? tournament.max_players_per_team.to_s : '')
    html.gsub!('{{MIN_PLAYERS}}', tournament.min_players_per_team ? tournament.min_players_per_team.to_s : '')
    
    # Format rules - split by newlines if present
    if tournament.rules_and_regulations.present?
      rules_text = tournament.rules_and_regulations.to_plain_text
      # Split by common separators and create list items
      rules_list = rules_text.split(/\n+|\.\s+/).reject(&:blank?).map { |r| r.strip }
      if rules_list.any?
        rules_html = rules_list.map { |rule| "<li>#{rule}</li>" }.join("\n")
        html.gsub!('{{RULES}}', rules_html)
      else
        html.gsub!('{{RULES}}', "<li>#{rules_text}</li>")
      end
    else
      html.gsub!('{{RULES}}', '<li>Rules will be announced soon</li>')
    end
    
    # Use organized_by field if present, otherwise fall back to created_by user name
    organizer_name = if tournament.respond_to?(:organized_by) && tournament.organized_by.present?
      tournament.organized_by
    elsif tournament.created_by.present?
      tournament.created_by.name
    else
      'Organizer'
    end
    html.gsub!('{{CREATED_BY}}', organizer_name)
    html.gsub!('{{PINCODE}}', tournament.pincode || '')
    
    # Add contact phones placeholder with proper HTML structure and tel: links for dialpad
    contact_phones_html = ''
    if tournament.respond_to?(:contact_phones) && tournament.contact_phones.present?
      phones = tournament.contact_phones.is_a?(String) ? JSON.parse(tournament.contact_phones) : tournament.contact_phones
      if phones.is_a?(Array) && phones.any?
        # Clean phone numbers (remove spaces, dashes, etc. for tel: links)
        phone_links = phones.map do |phone|
          clean_phone = phone.to_s.gsub(/[\s\-\(\)]/, '')
          "<a href='tel:#{clean_phone}' onclick='return true;'>#{phone}</a>"
        end.join('')
        contact_phones_html = %Q{
<div class="theme-contact-phones">
  <h4>📞 Contact</h4>
  #{phone_links}
</div>
        }.strip
      end
    end
    # Replace placeholder - use empty string if no phones (CSS will handle layout)
    html.gsub!('{{CONTACT_PHONES}}', contact_phones_html)
    
    # Add Google Maps QR code placeholder
    # Check multiple sources for Google Maps link
    gmap_link = nil
    
    # Priority 1: venue_google_maps_link field
    if tournament.respond_to?(:venue_google_maps_link) && tournament.venue_google_maps_link.present?
      gmap_link = tournament.venue_google_maps_link.to_s.strip
    # Priority 2: venue association google_maps_link
    elsif tournament.venue&.google_maps_link.present?
      gmap_link = tournament.venue.google_maps_link.to_s.strip
    # Priority 3: Generate from tournament latitude/longitude
    elsif tournament.latitude.present? && tournament.longitude.present?
      gmap_link = "https://www.google.com/maps?q=#{tournament.latitude},#{tournament.longitude}"
    end
    
    # Generate QR code if we have a valid Google Maps link
    if gmap_link.present? && gmap_link.start_with?('http')
      # Escape the Google Maps link for QR code URL
      escaped_gmap_link = CGI.escape(gmap_link)
      # Use appropriate size - CSS will constrain it further for responsiveness
      qr_code_url = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=#{escaped_gmap_link}"
      # Create QR code HTML - ensure proper HTML structure with responsive attributes
      qr_code_html = %Q{
<div class="theme-qr-code">
  <h4>Scan for Location</h4>
  <img src="#{qr_code_url}" alt="Google Maps QR Code" />
  <br/>
  <a href="#{gmap_link}" target="_blank">Open in Google Maps</a>
  <br/>
  <small>Scan QR code to open location</small>
</div>
      }.strip
      html.gsub!('{{GOOGLE_MAPS_QR}}', qr_code_html)
    else
      # Empty string if no QR code (CSS will handle layout)
      html.gsub!('{{GOOGLE_MAPS_QR}}', '')
    end
    
    # Replace prize placeholders
    html.gsub!('{{FIRST_PRIZE}}', tournament.first_prize ? "₹#{tournament.first_prize}" : '₹0')
    html.gsub!('{{SECOND_PRIZE}}', tournament.second_prize ? "₹#{tournament.second_prize}" : '₹0')
    html.gsub!('{{THIRD_PRIZE}}', tournament.third_prize ? "₹#{tournament.third_prize}" : '₹0')
    
    # Generate prizes HTML for dynamic prize display
    # Collect all prizes into an array for sorting
    prizes_array = []
    
    if tournament.first_prize.present? && tournament.first_prize > 0
      prizes_array << { label: 'First Prize', amount: tournament.first_prize }
    end
    if tournament.second_prize.present? && tournament.second_prize > 0
      prizes_array << { label: 'Second Prize', amount: tournament.second_prize }
    end
    if tournament.third_prize.present? && tournament.third_prize > 0
      prizes_array << { label: 'Third Prize', amount: tournament.third_prize }
    end
    
    # Add additional prizes from JSON
    if tournament.prizes_json.present?
      prizes_data = tournament.prizes_json
      # Handle both string and hash formats
      if prizes_data.is_a?(String)
        begin
          prizes_data = JSON.parse(prizes_data)
        rescue JSON::ParserError
          prizes_data = {}
        end
      end
      # Ensure it's a hash before iterating
      if prizes_data.is_a?(Hash) && prizes_data.any?
        prizes_data.each do |level, amount|
          next unless amount.present?
          amount_value = amount.to_f
          next if amount_value <= 0
          prizes_array << { label: level.to_s.humanize, amount: amount_value }
        end
      end
    end
    
    # Sort prizes by amount (descending) and generate HTML
    prizes_array = prizes_array.sort_by { |p| -p[:amount] }
    prizes_html = ''
    if prizes_array.any?
      prizes_array.each do |prize|
        prizes_html += "<div class=\"theme-prize-box\"><div class=\"theme-prize-label\">#{prize[:label]}</div><div class=\"theme-prize-amount\">₹#{prize[:amount].to_i}</div></div>"
      end
    end
    
    html.gsub!('{{PRIZES}}', prizes_html.presence || '<div class="theme-prize-box"><div class="theme-prize-label">Prizes</div><div class="theme-prize-amount">TBA</div></div>')
    
    # Replace color scheme if available
    if theme.color_scheme.present?
      begin
        colors = JSON.parse(theme.color_scheme)
        colors.each do |key, value|
          html.gsub!("{{COLOR_#{key.upcase}}}", value.to_s)
        end
      rescue JSON::ParserError
        # Ignore if color_scheme is not valid JSON
      end
    end
    
    html.html_safe
  end
end
