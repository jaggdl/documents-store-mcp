class Document < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :content, presence: true

  scope :search, ->(query) { where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%") }

  def content_as_html
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      no_images: false,
      no_links: false,
      no_styles: true,
      safe_links_only: true,
      with_toc_data: true,
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true
    )

    markdown.render(content).html_safe
  end

  def content_preview(length = 150)
    strip_tags(content_as_html).truncate(length)
  end

  private

  def strip_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end
end
