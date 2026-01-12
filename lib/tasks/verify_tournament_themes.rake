namespace :tournament_themes do
  desc "Verify tournament theme structure and contact phones"
  task verify: :environment do
    puts "Verifying tournament themes..."
    puts "=" * 60
    
    TournamentTheme.all.each do |theme|
      puts "\nTheme: #{theme.name}"
      puts "-" * 60
      
      # Check if template has contact-qr-container
      if theme.template_html.include?('theme-contact-qr-container')
        puts "✓ Has contact-qr-container"
      else
        puts "✗ MISSING: theme-contact-qr-container"
      end
      
      # Check if template has CONTACT_PHONES placeholder
      if theme.template_html.include?('{{CONTACT_PHONES}}')
        puts "✓ Has {{CONTACT_PHONES}} placeholder"
      else
        puts "✗ MISSING: {{CONTACT_PHONES}} placeholder"
      end
      
      # Check if template has GOOGLE_MAPS_QR placeholder
      if theme.template_html.include?('{{GOOGLE_MAPS_QR}}')
        puts "✓ Has {{GOOGLE_MAPS_QR}} placeholder"
      else
        puts "✗ MISSING: {{GOOGLE_MAPS_QR}} placeholder"
      end
      
      # Check order: rules should come before contact-qr-container
      rules_pos = theme.template_html.index('theme-rules')
      container_pos = theme.template_html.index('theme-contact-qr-container')
      
      if rules_pos && container_pos
        if rules_pos < container_pos
          puts "✓ Rules section comes before contact-qr-container"
        else
          puts "✗ ERROR: Rules section comes AFTER contact-qr-container"
        end
      end
      
      # Check if CONTACT_PHONES comes before GOOGLE_MAPS_QR in container
      contact_pos = theme.template_html.index('{{CONTACT_PHONES}}')
      qr_pos = theme.template_html.index('{{GOOGLE_MAPS_QR}}')
      
      if contact_pos && qr_pos
        if contact_pos < qr_pos
          puts "✓ Contact phones come before QR code in container"
        else
          puts "✗ ERROR: Contact phones come AFTER QR code"
        end
      end
    end
    
    puts "\n" + "=" * 60
    puts "Checking tournaments with contact phones..."
    
    tournaments_with_phones = Tournament.where.not(contact_phones: nil).limit(5)
    if tournaments_with_phones.any?
      puts "Found #{tournaments_with_phones.count} tournaments with contact phones"
      tournaments_with_phones.each do |tournament|
        puts "\nTournament: #{tournament.title}"
        puts "  Contact phones: #{tournament.contact_phones.inspect}"
        puts "  Has theme: #{tournament.tournament_theme.present? ? 'Yes' : 'No'}"
        if tournament.tournament_theme.present?
          puts "  Theme: #{tournament.tournament_theme.name}"
        end
      end
    else
      puts "⚠ No tournaments found with contact phones"
    end
    
    puts "\nVerification complete!"
  end
end
