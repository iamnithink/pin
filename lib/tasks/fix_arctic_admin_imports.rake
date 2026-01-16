# Patch arctic_admin to fix SassC compatibility issues
namespace :assets do
  desc "Fix arctic_admin for SassC compatibility - fixes glob imports and incompatible units"
  task :fix_arctic_admin_imports do
    begin
      arctic_admin_spec = Gem::Specification.find_by_name("arctic_admin")
      arctic_admin_dir = File.join(arctic_admin_spec.gem_dir, "app/assets/stylesheets/arctic_admin")
      arctic_admin_path = File.join(arctic_admin_dir, "_base.scss")
      
      unless File.exist?(arctic_admin_path)
        puts "ERROR: arctic_admin _base.scss not found at #{arctic_admin_path}"
        return
      end
      
      puts "Fixing arctic_admin in: #{arctic_admin_dir}"
      
      # 1. Fix glob imports
      content = File.read(arctic_admin_path)
      components = %w[components/_columns components/_comments components/_date_picker components/_dialogs components/_flash components/_form components/_inputs components/_panel_contents components/_pagination components/_select2 components/_status_tag components/_tabs components/_tables components/_toggle]
      layouts = %w[layouts/_filter layouts/_footer layouts/_header layouts/_main_content layouts/_sidebar layouts/_wrapper]
      pages = %w[pages/_form pages/_index pages/_login pages/_show]
      
      new_content = content.gsub(/@import "components\/\*";/, components.map { |c| "@import \"#{c}\";" }.join("\n"))
                           .gsub(/@import "layouts\/\*";/, layouts.map { |l| "@import \"#{l}\";" }.join("\n"))
                           .gsub(/@import "pages\/\*";/, pages.map { |p| "@import \"#{p}\";" }.join("\n"))
      
      if new_content != content
        File.write(arctic_admin_path, new_content)
        puts "✓ Fixed glob imports in _base.scss"
      end
      
      # 2. Fix ALL SCSS files - replace variables and fix margin shorthand
      fixed_count = 0
      Dir.glob(File.join(arctic_admin_dir, "**/*.scss")).each do |scss_file|
        next if scss_file.include?('variables/_size.scss')
        
        content = File.read(scss_file)
        original = content.dup
        
        # Replace variables with literal values
        content = content.gsub(/\$form-margin-left\b/, '25%')
        content = content.gsub(/\$form-input-width\b/, '50%')
        
        # Fix margin shorthand that mixes px and % - this is the main issue
        content = content.gsub(/margin:\s*(\d+)px\s+(\d+)px\s+(\d+)px\s+(25%|50%|\$form-margin-left|\$form-input-width|[^;]+);/) do |match|
          top, right, bottom, left = $1, $2, $3, $4
          left = '25%' if left.include?('form-margin-left') || left == '$form-margin-left'
          "margin-top: #{top}px; margin-right: #{right}px; margin-bottom: #{bottom}px; margin-left: #{left};"
        end
        
        if content != original
          File.write(scss_file, content)
          puts "✓ Fixed #{File.basename(scss_file)}"
          fixed_count += 1
        end
      end
      
      # 3. Comment out variable definitions
      size_scss = File.join(arctic_admin_dir, "variables/_size.scss")
      if File.exist?(size_scss)
        content = File.read(size_scss)
        new_content = content.gsub(/\$form-margin-left:\s*.*?;/, '// $form-margin-left: 25% !default; // Fixed by rake task')
                              .gsub(/\$form-input-width:\s*.*?;/, '// $form-input-width: 50% !default; // Fixed by rake task')
        
        if new_content != content
          File.write(size_scss, new_content)
          puts "✓ Commented out variable definitions"
        end
      end
      
      puts "✅ Fixed #{fixed_count} SCSS files"
      puts "✅ Arctic Admin is now SassC compatible"
      
    rescue => e
      puts "ERROR: #{e.message}"
      puts e.backtrace.first(5)
      raise
    end
  end
end
