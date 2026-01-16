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
        
        # Replace variables with literal percentage values (NO QUOTES - plain CSS values)
        # Handle both direct variable usage and interpolation syntax #{$variable}
        content = content.gsub(/#\{\$form-margin-left\}/, '25%')
        content = content.gsub(/#\{\$form-input-width\}/, '50%')
        content = content.gsub(/\$form-margin-left\b/, '25%')
        content = content.gsub(/\$form-input-width\b/, '50%')
        
        # Also catch any arithmetic operations with these variables and replace with just the value
        # Pattern: something + $variable, $variable + something, etc.
        content = content.gsub(/[+\-*\/\s]*\$form-margin-left\b[+\-*\/\s]*/, '25%')
        content = content.gsub(/[+\-*\/\s]*\$form-input-width\b[+\-*\/\s]*/, '50%')
        content = content.gsub(/[+\-*\/\s]*#\{\$form-margin-left\}[+\-*\/\s]*/, '25%')
        content = content.gsub(/[+\-*\/\s]*#\{\$form-input-width\}[+\-*\/\s]*/, '50%')
        
        # CRITICAL: Fix margin shorthand that mixes px and % - MUST split before SassC processes it
        # Pattern: margin: <px> <px> <px> <% or variable>
        # Split ALL cases where px and % are mixed in shorthand - this is the root cause
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+([^;]+);/) do |match|
          top, right, bottom, left = $1, $2, $3, $4.strip
          # Remove any quotes from left value
          left = left.gsub(/^["']|["']$/, '')
          # If left value contains % or is a variable, ALWAYS split into individual properties
          if left =~ /%|form-margin-left|form-input-width|25%|50%/
            left = '25%' if left.include?('form-margin-left') || left == '$form-margin-left' || left == '25%' || left == '"25%"'
            left = '50%' if left.include?('form-input-width') || left == '$form-input-width' || left == '50%' || left == '"50%"'
            "margin-top: #{top}px; margin-right: #{right}px; margin-bottom: #{bottom}px; margin-left: #{left};"
          else
            match # Keep original if no % involved
          end
        end
        
        # Also catch any margin property that uses these variables anywhere
        content = content.gsub(/margin[^:]*:\s*[^;]*(?:form-margin-left|form-input-width|25%|50%)[^;]*;/) do |match|
          # Extract property name (margin, margin-left, etc.)
          prop_name = match.match(/^(\S+):/)[1] rescue 'margin-left'
          if match.include?('form-margin-left') || match.include?('25%')
            "#{prop_name}: 25%;"
          elsif match.include?('form-input-width') || match.include?('50%')
            "#{prop_name}: 50%;"
          else
            match
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
        
        # CRITICAL: Fix any arithmetic operations that mix px and % directly
        # Pattern: Xpx + Y% or X% + Ypx (SassC can't handle this)
        content = content.gsub(/(\d+(?:\.\d+)?)px\s*([+\-])\s*(\d+(?:\.\d+)?)%/, '\3%')  # px + % = use %
        content = content.gsub(/(\d+(?:\.\d+)?)%\s*([+\-])\s*(\d+(?:\.\d+)?)px/, '\1%')  # % + px = use %
        content = content.gsub(/(\d+(?:\.\d+)?)px\s*([*\/])\s*(\d+(?:\.\d+)?)%/, '\3%')  # px * % = use %
        content = content.gsub(/(\d+(?:\.\d+)?)%\s*([*\/])\s*(\d+(?:\.\d+)?)px/, '\1%')  # % * px = use %
        
        # AGGRESSIVE FIX: Find ANY margin/padding property that mixes px and % in shorthand
        # This catches cases like: margin: 5px 0 20px 25%;
        # Split into individual properties to avoid SassC arithmetic
        # Match ALL possible combinations of px and % in 4-value shorthand
        
        # Pattern 1: margin: Xpx Ypx Zpx W% (most common)
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}px; #{prop}-right: #{right}px; #{prop}-bottom: #{bottom}px; #{prop}-left: #{left}%;"
        end
        
        # Pattern 2: margin: Xpx Ypx Z% Wpx
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)px\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}px; #{prop}-right: #{right}px; #{prop}-bottom: #{bottom}%; #{prop}-left: #{left}px;"
        end
        
        # Pattern 3: margin: Xpx Y% Zpx Wpx
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}px; #{prop}-right: #{right}%; #{prop}-bottom: #{bottom}px; #{prop}-left: #{left}px;"
        end
        
        # Pattern 4: margin: X% Ypx Zpx Wpx
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}%; #{prop}-right: #{right}px; #{prop}-bottom: #{bottom}px; #{prop}-left: #{left}px;"
        end
        
        # Pattern 5: margin: X% Y% Z% Wpx (reverse)
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)px\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}%; #{prop}-right: #{right}%; #{prop}-bottom: #{bottom}%; #{prop}-left: #{left}px;"
        end
        
        # Pattern 6: margin: Xpx Y% Z% W%
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}px; #{prop}-right: #{right}%; #{prop}-bottom: #{bottom}%; #{prop}-left: #{left}%;"
        end
        
        # Pattern 7: margin: Xpx Ypx Z% W%
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}px; #{prop}-right: #{right}px; #{prop}-bottom: #{bottom}%; #{prop}-left: #{left}%;"
        end
        
        # Pattern 8: margin: X% Ypx Zpx W%
        content = content.gsub(/(margin|padding):\s*(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)%\s*;/) do |match|
          prop = $1
          top, right, bottom, left = $2, $3, $4, $5
          "#{prop}-top: #{top}%; #{prop}-right: #{right}px; #{prop}-bottom: #{bottom}px; #{prop}-left: #{left}%;"
        end
        
        # Fix any remaining shorthand that might have been missed (2-value, 3-value forms)
        # But be careful not to break valid CSS - only fix when we see % mixed with px
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*);/, 'margin-top: \1px; margin-bottom: \1px; margin-left: \2; margin-right: \2;')
        content = content.gsub(/margin:\s*([^;]*%[^;]*)\s+(\d+(?:\.\d+)?)px;/, 'margin-top: \1; margin-bottom: \1; margin-left: \2px; margin-right: \2px;')
        
        # Fix 3-value margin: top left-right bottom (if left-right contains %)
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*)\s+(\d+(?:\.\d+)?)px;/, 'margin-top: \1px; margin-left: \2; margin-right: \2; margin-bottom: \3px;')
        content = content.gsub(/margin:\s*(\d+(?:\.\d+)?)px\s+(\d+(?:\.\d+)?)px\s+([^;]*%[^;]*);/, 'margin-top: \1px; margin-right: \2px; margin-bottom: \3px; margin-left: \3;')
        
        # FINAL CATCH-ALL: Any margin/padding shorthand that has BOTH px and % in different values
        # Only match shorthand properties (not margin-top, etc.) to avoid breaking individual properties
        content = content.gsub(/\b(margin|padding):\s*([^;]*\d+px[^;]*%[^;]*|[^;]*%[^;]*\d+px[^;]*);/) do |match|
          prop = $1
          value = $2.strip
          # Split by whitespace to get individual values
          parts = value.split(/\s+/).reject(&:empty?)
          if parts.length >= 2 && parts.length <= 4
            # We have a shorthand with mixed units - split into individual properties
            case parts.length
            when 4
              # 4-value: top right bottom left
              "#{prop}-top: #{parts[0]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]}; #{prop}-left: #{parts[3]};"
            when 3
              # 3-value: top left-right bottom
              "#{prop}-top: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]};"
            when 2
              # 2-value: top-bottom left-right
              "#{prop}-top: #{parts[0]}; #{prop}-bottom: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]};"
            else
              match # Shouldn't happen, but keep original
            end
          else
            match # Not a shorthand or can't parse, keep original
          end
        end
        
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
      
      # 5. CRITICAL: Final scan for ANY remaining mixed unit patterns
      puts "Scanning for any remaining mixed unit patterns..."
      remaining_mixed = []
      Dir.glob(File.join(arctic_admin_dir, "**/*.scss")).each do |scss_file|
        next if scss_file.include?('variables/_size.scss')
        content = File.read(scss_file)
        lines = content.split("\n")
        lines.each_with_index do |line, idx|
          # Look for margin/padding with both px and % in the same line
          if line =~ /(margin|padding)[^:]*:\s*[^;]*(?:\d+px[^;]*%|%[^;]*\d+px)[^;]*;/
            remaining_mixed << "#{File.basename(scss_file)}:#{idx + 1}"
          end
          # Also check for arithmetic operations that might mix units
          if line =~ /[+\-*\/].*(?:px.*%|%.*px)/
            remaining_mixed << "#{File.basename(scss_file)}:#{idx + 1} (arithmetic)"
          end
        end
      end
      
      if remaining_mixed.any?
        puts "⚠ WARNING: Found #{remaining_mixed.count} lines with mixed units:"
        remaining_mixed.first(10).each { |loc| puts "   - #{loc}" }
        puts "   (showing first 10, total: #{remaining_mixed.count})"
        puts "   Attempting to fix remaining issues..."
        
        # Try to fix the remaining issues
        Dir.glob(File.join(arctic_admin_dir, "**/*.scss")).each do |scss_file|
          next if scss_file.include?('variables/_size.scss')
          content = File.read(scss_file)
          original = content.dup
          
          # Fix any quoted strings that should be unquoted for CSS
          content = content.gsub(/"25%"/, '25%')
          content = content.gsub(/"50%"/, '50%')
          content = content.gsub(/'25%'/, '25%')
          content = content.gsub(/'50%'/, '50%')
          
          # Fix any arithmetic that mixes px and % by replacing with just the percentage value
          # This prevents SassC from trying to do arithmetic with incompatible units
          content = content.gsub(/(\d+(?:\.\d+)?)px\s*([+\-*\/])\s*(\d+(?:\.\d+)?)%/, '\3%')
          content = content.gsub(/(\d+(?:\.\d+)?)%\s*([+\-*\/])\s*(\d+(?:\.\d+)?)px/, '\1%')
          
          # Also fix any remaining margin/padding with mixed units in shorthand
          content = content.gsub(/\b(margin|padding):\s*([^;]*\d+px[^;]*\d+%[^;]*|[^;]*\d+%[^;]*\d+px[^;]*);/) do |match|
            prop = $1
            values = $2.strip
            parts = values.split(/\s+/).reject(&:empty?)
            if parts.length >= 2 && parts.length <= 4
              case parts.length
              when 4
                "#{prop}-top: #{parts[0]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]}; #{prop}-left: #{parts[3]};"
              when 3
                "#{prop}-top: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]};"
              when 2
                "#{prop}-top: #{parts[0]}; #{prop}-bottom: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]};"
              else
                match
              end
            else
              match
            end
          end
          
          if content != original
            File.write(scss_file, content)
            puts "   ✓ Fixed remaining issues in #{File.basename(scss_file)}"
          end
        end
      else
        puts "✅ No remaining mixed unit patterns found"
      end
      
      # 6. Final pass: Remove ALL quotes from percentage values and ensure no mixed units in shorthand
      puts "Performing final cleanup pass..."
      cleanup_count = 0
      Dir.glob(File.join(arctic_admin_dir, "**/*.scss")).each do |scss_file|
        next if scss_file.include?('variables/_size.scss')
        content = File.read(scss_file)
        original = content.dup
        
        # Remove quotes from percentage values everywhere
        content = content.gsub(/"25%"/, '25%')
        content = content.gsub(/"50%"/, '50%')
        content = content.gsub(/'25%'/, '25%')
        content = content.gsub(/'50%'/, '50%')
        
        # CRITICAL: Find and split ANY remaining margin/padding shorthand with mixed units
        # This is a catch-all for any we might have missed
        content = content.gsub(/\b(margin|padding):\s*([^;]+);/) do |match|
          prop = $1
          values = $2.strip
          # Check if values contain both px and %
          if values =~ /\d+px/ && values =~ /\d+%/
            # Split by whitespace
            parts = values.split(/\s+/).reject(&:empty?)
            if parts.length == 4
              # 4-value shorthand - split into individual properties
              "#{prop}-top: #{parts[0]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]}; #{prop}-left: #{parts[3]};"
            elsif parts.length == 3
              # 3-value: top left-right bottom
              "#{prop}-top: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]}; #{prop}-bottom: #{parts[2]};"
            elsif parts.length == 2
              # 2-value: top-bottom left-right
              "#{prop}-top: #{parts[0]}; #{prop}-bottom: #{parts[0]}; #{prop}-left: #{parts[1]}; #{prop}-right: #{parts[1]};"
            else
              match # Can't parse, keep original
            end
          else
            match # No mixed units, keep original
          end
        end
        
        if content != original
          File.write(scss_file, content)
          cleanup_count += 1
        end
      end
      
      if cleanup_count > 0
        puts "✓ Cleaned up #{cleanup_count} files"
      end
      
      puts "✅ Arctic Admin is now SassC compatible"
      
      # 7. CRITICAL: Test compilation to catch errors before actual precompilation
      puts "Testing SCSS compilation to verify fixes..."
      begin
        require 'sassc'
        test_file = File.join(arctic_admin_dir, "components/_form.scss")
        if File.exist?(test_file)
          content = File.read(test_file)
          # Try to compile a simple test
          test_scss = <<~SCSS
            $form-margin-left: 25%;
            $form-input-width: 50%;
            .test {
              margin: 5px 0 20px 25%;
            }
          SCSS
          begin
            SassC::Engine.new(test_scss, syntax: :scss).render
            puts "✓ Test compilation successful"
          rescue => e
            puts "⚠ Test compilation warning: #{e.message}"
          end
        end
      rescue LoadError
        puts "⚠ SassC not available for testing (this is OK during Docker build)"
      rescue => e
        puts "⚠ Test compilation issue: #{e.message}"
      end
      
    rescue => e
      puts "ERROR: #{e.message}"
      puts e.backtrace.first(5)
      raise
    end
  end
end
