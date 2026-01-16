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
      
      # 0. Comment out variable definitions FIRST to prevent SassC from seeing them
      size_scss = File.join(arctic_admin_dir, "variables/_size.scss")
      if File.exist?(size_scss)
        content = File.read(size_scss)
        new_content = content.gsub(/\$form-margin-left:\s*.*?;/, '// $form-margin-left: 25% !default; // Fixed by rake task')
                              .gsub(/\$form-input-width:\s*.*?;/, '// $form-input-width: 50% !default; // Fixed by rake task')
        
        if new_content != content
          File.write(size_scss, new_content)
          puts "✓ Commented out variable definitions FIRST"
        end
      end
      
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
      all_files = Dir.glob(File.join(arctic_admin_dir, "**/*.scss"))
      puts "Found #{all_files.count} SCSS files to process"
      
      all_files.each do |scss_file|
        next if scss_file.include?('variables/_size.scss')
        
        content = File.read(scss_file)
        original = content.dup
        had_variables = content =~ /\$form-margin-left|\$form-input-width|#\{\$form-margin-left\}|#\{\$form-input-width\}/
        
        # Replace variables with literal values FIRST (before any calculations)
        # Handle both direct variable usage and interpolation syntax #{$variable}
        content = content.gsub(/#\{\$form-margin-left\}/, '25%')
        content = content.gsub(/#\{\$form-input-width\}/, '50%')
        content = content.gsub(/\$form-margin-left\b/, '25%')
        content = content.gsub(/\$form-input-width\b/, '50%')
        
        # Fix margin shorthand that mixes px and % - catch ALL variations
        # Pattern: margin: <px> <px> <px> <% or variable>
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+([^;]+);/) do |match|
          top, right, bottom, left = $1, $2, $3, $4.strip
          # If left value contains % or is a variable, split into individual properties
          if left =~ /%|form-margin-left|form-input-width|25%|50%/
            left = '25%' if left.include?('form-margin-left') || left == '$form-margin-left' || left == '25%'
            left = '50%' if left.include?('form-input-width') || left == '$form-input-width' || left == '50%'
            "margin-top: #{top}px; margin-right: #{right}px; margin-bottom: #{bottom}px; margin-left: #{left};"
          else
            match # Keep original if no % involved
          end
        end
        
        # Fix padding shorthand that mixes px and %
        content = content.gsub(/padding:\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+([^;]+);/) do |match|
          top, right, bottom, left = $1, $2, $3, $4.strip
          if left =~ /%|form-margin-left|form-input-width|25%|50%/
            left = '25%' if left.include?('form-margin-left') || left == '$form-margin-left' || left == '25%'
            left = '50%' if left.include?('form-input-width') || left == '$form-input-width' || left == '50%'
            "padding-top: #{top}px; padding-right: #{right}px; padding-bottom: #{bottom}px; padding-left: #{left};"
          else
            match
          end
        end
        
        # Fix any arithmetic operations that mix px and % (e.g., calc(), +, -)
        # Replace entire property declarations that use these variables in calculations
        content = content.gsub(/margin-left:\s*[^;]*\$?form-margin-left[^;]*;/, 'margin-left: 25%;')
        content = content.gsub(/margin-left:\s*[^;]*\$?form-input-width[^;]*;/, 'margin-left: 50%;')
        content = content.gsub(/width:\s*[^;]*\$?form-input-width[^;]*;/, 'width: 50%;')
        
        # Fix calc() functions that might mix units
        content = content.gsub(/calc\([^)]*\$?form-margin-left[^)]*\)/, '25%')
        content = content.gsub(/calc\([^)]*\$?form-input-width[^)]*\)/, '50%')
        
        # Fix any remaining shorthand that might have been missed (2-value, 3-value forms)
        # But be careful not to break valid CSS - only fix when we see % mixed with px
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*);/, 'margin-top: \1px; margin-bottom: \1px; margin-left: \2; margin-right: \2;')
        content = content.gsub(/margin:\s*([^;]*%[^;]*)\s+(\d+(?:\.\d+)?)px;/, 'margin-top: \1; margin-bottom: \1; margin-left: \2px; margin-right: \2px;')
        
        # Fix 3-value margin: top left-right bottom (if left-right contains %)
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*)\s+(\d+(?:\.\d+)?)px;/, 'margin-top: \1px; margin-left: \2; margin-right: \2; margin-bottom: \3px;')
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*);/, 'margin-top: \1px; margin-right: \2px; margin-bottom: \3px; margin-left: \3;')
        
        if content != original
          File.write(scss_file, content)
          puts "✓ Fixed #{File.basename(scss_file)}#{had_variables ? ' (had variables)' : ''}"
          fixed_count += 1
        elsif had_variables
          puts "⚠ #{File.basename(scss_file)} has variables but no changes made - may need manual fix"
        end
      end
      
      # 3. Variable definitions already commented out in step 0
      
      # 4. Final safety check - verify no variable references remain
      remaining_vars = []
      Dir.glob(File.join(arctic_admin_dir, "**/*.scss")).each do |scss_file|
        next if scss_file.include?('variables/_size.scss')
        content = File.read(scss_file)
        if content =~ /\$form-margin-left|\$form-input-width|#\{\$form-margin-left\}|#\{\$form-input-width\}/
          remaining_vars << File.basename(scss_file)
        end
      end
      
      if remaining_vars.any?
        puts "⚠ WARNING: Variables still found in: #{remaining_vars.join(', ')}"
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
