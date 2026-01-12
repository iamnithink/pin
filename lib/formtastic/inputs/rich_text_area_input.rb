module Formtastic
  module Inputs
    class RichTextAreaInput < TextInput
      def to_html
        input_wrapping do
          label_html <<
          template.content_tag(:div, class: 'trix-wrapper') do
            template.rich_text_area(
              builder.object_name,
              method,
              input_html_options.merge(
                id: input_html_options[:id] || "#{builder.object_name}_#{method}",
                class: [input_html_options[:class], 'trix-content'].compact.join(' '),
                placeholder: input_html_options[:placeholder] || 'Start typing...'
              )
            )
          end
        end
      end
      
      private
      
      def template
        @template ||= builder.template
      end
    end
  end
end

