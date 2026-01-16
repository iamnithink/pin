# Patch arctic_admin _base.scss to replace glob imports with explicit imports
# This fixes SassC compatibility issues
namespace :assets do
  desc "Fix arctic_admin glob imports for SassC compatibility"
  task :fix_arctic_admin_imports do
    # Find arctic_admin gem path
    arctic_admin_spec = Gem::Specification.find_by_name("arctic_admin")
    arctic_admin_path = File.join(arctic_admin_spec.gem_dir, "app/assets/stylesheets/arctic_admin/_base.scss")
    if arctic_admin_path && File.exist?(arctic_admin_path)
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
      replacement = components.map { |c| "@import \"#{c}\";" }.join("\n")
      replacement += "\n" + layouts.map { |l| "@import \"#{l}\";" }.join("\n")
      replacement += "\n" + pages.map { |p| "@import \"#{p}\";" }.join("\n")
      
      new_content = content.gsub(/@import "components\/\*";/, replacement.split("\n").first(components.length).join("\n"))
                           .gsub(/@import "layouts\/\*";/, layouts.map { |l| "@import \"#{l}\";" }.join("\n"))
                           .gsub(/@import "pages\/\*";/, pages.map { |p| "@import \"#{p}\";" }.join("\n"))
      
      if new_content != content
        File.write(arctic_admin_path, new_content)
        puts "Fixed arctic_admin imports in #{arctic_admin_path}"
      else
        puts "No changes needed in #{arctic_admin_path}"
      end
    else
      puts "arctic_admin _base.scss not found"
    end
  end
end
