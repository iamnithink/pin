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
end

