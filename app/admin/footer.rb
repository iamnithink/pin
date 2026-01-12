module ActiveAdmin
  module Views
    class Footer < Component
      def build(*args)
        # Don't call super to avoid rendering default footer
        div id: "footer", style: "text-align: center;" do
          small "All rights reserved © 2026 PIN(PlayInNear)"
        end
      end
    end
  end
end

