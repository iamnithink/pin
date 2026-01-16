if defined?(Bullet)
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true

  # Safelist admin counter cache warnings that are acceptable (Bullet 7 uses add_safelist)
  Bullet.add_safelist(type: :counter_cache, class_name: 'Sport', association: :matches)
  Bullet.add_safelist(type: :counter_cache, class_name: 'Venue', association: :matches)
  Bullet.add_safelist(type: :counter_cache, class_name: 'CricketMatchType', association: :matches)
  
  # Safelist venue association - it's only accessed conditionally as fallback when venue_address is blank
  # Most tournaments use venue_address field directly, so lazy loading is acceptable
  Bullet.add_safelist(type: :n_plus_one_query, class_name: 'Tournament', association: :venue)
end

