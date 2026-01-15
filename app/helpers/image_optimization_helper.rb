module ImageOptimizationHelper
  # Generate optimized image URL with Cloudinary transformations
  # This significantly improves page load speed and UX
  def optimized_image_url(attachment, options = {})
    return nil unless attachment&.attached?
    
    # Default optimizations for performance
    width = options[:width] || options[:w]
    height = options[:height] || options[:h]
    quality = options[:quality] || 'auto:good' # Auto quality with good compression
    format = options[:format] || 'auto' # Auto format (WebP, AVIF when supported)
    crop = options[:crop] || 'limit' # Limit crop to maintain aspect ratio
    
    # Get base URL from ActiveStorage
    base_url = url_for(attachment)
    
    # If using Cloudinary, add transformation parameters to the URL
    if ENV['CLOUDINARY_CLOUD_NAME'].present? && base_url.include?('cloudinary.com')
      # Cloudinary URL format: https://res.cloudinary.com/cloud_name/image/upload/v1234567890/folder/file.jpg
      # We need to insert transformations: /upload/transformations/v1234567890/folder/file.jpg
      
      # Build transformation string
      transformations = []
      transformations << "w_#{width}" if width.present? && width != 'auto'
      transformations << "h_#{height}" if height.present? && height != 'auto'
      transformations << "c_#{crop}"
      transformations << "q_#{quality}"
      transformations << "f_#{format}"
      transformations << "g_#{options[:gravity]}" if options[:gravity]
      
      # Insert transformations into Cloudinary URL
      if base_url.include?('/upload/')
        # Replace /upload/ with /upload/transformations/
        base_url.sub('/upload/', "/upload/#{transformations.join(',')}/")
      else
        base_url
      end
    else
      # Fallback for local storage - use ActiveStorage variants
      if width || height
        variant_options = {}
        variant_options[:resize_to_limit] = [width || 1200, height || 800] if width || height
        begin
          url_for(attachment.variant(variant_options))
        rescue
          base_url
        end
      else
        base_url
      end
    end
  end
  
  # Generate responsive image srcset for different screen sizes
  # This loads appropriate image size based on device, improving mobile performance
  def responsive_image_srcset(attachment, sizes = [400, 800, 1200])
    return nil unless attachment&.attached?
    
    sizes.map do |size|
      "#{optimized_image_url(attachment, width: size, quality: 'auto:good', format: 'auto')} #{size}w"
    end.join(', ')
  end
  
  # Optimized image tag with performance features
  def optimized_image_tag(attachment, options = {})
    return nil unless attachment&.attached?
    
    # Extract image-specific options
    image_options = {}
    tag_options = {}
    
    # Separate image transformation options from HTML tag options
    [:width, :height, :quality, :format, :crop, :gravity, :w, :h].each do |key|
      image_options[key] = options.delete(key) if options.key?(key)
    end
    
    # Remaining options go to the image tag
    tag_options = options.dup
    
    # Set default performance attributes
    tag_options[:loading] ||= 'lazy' # Lazy load for better initial page load
    tag_options[:decoding] ||= 'async' # Async decoding for non-blocking rendering
    tag_options[:fetchpriority] ||= tag_options.delete(:priority) || 'auto'
    
    # Add responsive srcset if width is specified (for Cloudinary)
    if ENV['CLOUDINARY_CLOUD_NAME'].present? && (image_options[:width] || image_options[:w])
      width = image_options[:width] || image_options[:w]
      # Generate srcset with different sizes for responsive images
      srcset_parts = []
      [width, width * 2].each do |size|
        srcset_parts << "#{optimized_image_url(attachment, image_options.merge(width: size))} #{size}w"
      end
      tag_options[:srcset] = srcset_parts.join(', ')
      tag_options[:sizes] = tag_options[:sizes] || "(max-width: 768px) 100vw, #{width}px"
    end
    
    # Generate optimized URL
    optimized_url = optimized_image_url(attachment, image_options)
    
    # Create image tag
    image_tag(optimized_url, tag_options)
  end
end
