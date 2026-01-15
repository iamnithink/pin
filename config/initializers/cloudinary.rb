# Cloudinary Configuration - Optimized for Performance
# Free tier: 25GB storage, 25GB bandwidth/month
# Sign up at https://cloudinary.com/users/register/free
#
# Performance Benefits:
# - Global CDN (faster image delivery worldwide)
# - Automatic image optimization & compression
# - On-the-fly transformations (resize, format conversion)
# - Modern formats (WebP, AVIF) with automatic fallbacks
# - Lazy loading support
# - Responsive images
#
# Note: Only configured in production. Development uses local storage.

if Rails.env.production? && ENV['CLOUDINARY_CLOUD_NAME'].present?
  begin
    require 'cloudinary'
    Cloudinary.config do |config|
      config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
      config.api_key = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
      config.secure = true # Use HTTPS for security and performance
      config.cdn_subdomain = true # Enable CDN subdomain for better caching
    end
    Rails.logger.info "Cloudinary configured for production: #{ENV['CLOUDINARY_CLOUD_NAME']}"
  rescue LoadError => e
    Rails.logger.error "Cloudinary gem not available: #{e.message}"
  end
elsif Rails.env.production? && ENV['CLOUDINARY_CLOUD_NAME'].blank?
  Rails.logger.warn "WARNING: Cloudinary credentials not set in production. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET environment variables."
end
