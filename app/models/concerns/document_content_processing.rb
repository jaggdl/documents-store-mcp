module DocumentContentProcessing
  extend ActiveSupport::Concern

  def content_as_html
    Commonmarker.to_html(content, options: {
      parse: { smart: true }
    },
      plugins: {
        syntax_highlighter: {
          theme: "base16-ocean.dark"
        }
      },
                        ).html_safe
  end

  def content_preview(length = 150)
    strip_tags(content_as_html).truncate(length)
  end

  private

  def strip_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end
end
