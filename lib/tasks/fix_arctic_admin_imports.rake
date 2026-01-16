# Patch arctic_admin _base.scss to replace glob imports with explicit imports
# This fixes SassC compatibility issues
namespace :assets do
  desc "Fix arctic_admin glob imports for SassC compatibility"
  task :fix_arctic_admin_imports do
    # Find arctic_admin gem path
    arctic_admin_spec = Gem::Specification.find_by_name("arctic_admin")
    arctic_admin_dir = File.join(arctic_admin_spec.gem_dir, "app/assets/stylesheets/arctic_admin")
    arctic_admin_path = File.join(arctic_admin_dir, "_base.scss")
    
    if File.exist?(arctic_admin_path)
      content = File.read(arctic_admin_path)
      
      # Replace glob imports with explicit imports
      components = %w[
        components/_columns
        components/_comments
        components/_date_picker
        components/_dialogs
        components/_flash
        components/_form
        components/_inputs
        components/_panel_contents
        components/_pagination
        components/_select2
        components/_status_tag
        components/_tabs
        components/_tables
        components/_toggle
      ]
      
      layouts = %w[
        layouts/_filter
        layouts/_footer
        layouts/_header
        layouts/_main_content
        layouts/_sidebar
        layouts/_wrapper
      ]
      
      pages = %w[
        pages/_form
        pages/_index
        pages/_login
        pages/_show
      ]
      
      # Build replacement
      components_imports = components.map { |c| "@import \"#{c}\";" }.join("\n")
      layouts_imports = layouts.map { |l| "@import \"#{l}\";" }.join("\n")
      pages_imports = pages.map { |p| "@import \"#{p}\";" }.join("\n")
      
      new_content = content.gsub(/@import "components\/\*";/, components_imports)
                           .gsub(/@import "layouts\/\*";/, layouts_imports)
                           .gsub(/@import "pages\/\*";/, pages_imports)
      
      if new_content != content
        File.write(arctic_admin_path, new_content)
        puts "Fixed arctic_admin imports in #{arctic_admin_path}"
      else
        puts "No changes needed in #{arctic_admin_path}"
      end
      
      # Fix incompatible units issue - replace ALL variable usages with literal values
      # SassC can't handle percentage variables being used with pixel values
      [File.join(arctic_admin_dir, "components/_form.scss"),
       File.join(arctic_admin_dir, "pages/_form.scss")].each do |scss_file|
        next unless File.exist?(scss_file)
        
        content = File.read(scss_file)
        new_content = content
        
        # Replace ALL occurrences of the variables with literal values
        new_content = new_content.gsub(/\$form-margin-left/, '25%')
        new_content = new_content.gsub(/\$form-input-width/, '50%')
        
        # Ensure margin shorthand is split
        new_content = new_content.gsub(
          /margin:\s*5px\s+0\s+20px\s+[^;]+;/,
          'margin-top: 5px; margin-right: 0; margin-bottom: 20px; margin-left: 25%;'
        )
        
        if new_content != content
          File.write(scss_file, new_content)
          puts "Fixed variables in #{File.basename(scss_file)}"
        end
      end
      
      # Comment out variable definitions to prevent SassC from processing them
      # All usages have been replaced with literal values
      size_scss = File.join(arctic_admin_dir, "variables/_size.scss")
      if File.exist?(size_scss)
        content = File.read(size_scss)
        new_content = content.gsub(
          /\$form-margin-left:\s*.*?;/,
          '// $form-margin-left: 25% !default; // Commented out - all usages replaced with literal 25%'
        ).gsub(
          /\$form-input-width:\s*.*?;/,
          '// $form-input-width: 50% !default; // Commented out - all usages replaced with literal 50%'
        )
        
        if new_content != content
          File.write(size_scss, new_content)
          puts "Commented out variable definitions in variables/_size.scss"
        end
      end
    else
      puts "arctic_admin _base.scss not found"
    end
  end
end
