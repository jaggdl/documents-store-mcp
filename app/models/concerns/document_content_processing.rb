module DocumentContentProcessing
  extend ActiveSupport::Concern

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

  def content_highlights(query, max_highlights: 3, snippet_length: 150)
    return [content_preview(snippet_length)] if query.blank?

    text = strip_tags(content_as_html)
    return [text.truncate(snippet_length)] if text.length <= snippet_length

    query_terms = query.downcase.split(/\s+/).reject(&:blank?)
    return [text.truncate(snippet_length)] if query_terms.empty?

    highlights = []
    
    query_terms.each do |term|
      text.scan(/(.{0,#{snippet_length/3}}#{Regexp.escape(term)}.{0,#{snippet_length/3}})/i) do |match|
        snippet = match[0].strip
        next if snippet.length < 10
        
        highlights << {
          text: snippet,
          score: calculate_snippet_score(snippet, query_terms),
          term: term
        }
      end
    end

    if highlights.empty?
      sentences = text.split(/[.!?]+/).reject(&:blank?)
      scored_sentences = sentences.map do |sentence|
        {
          text: sentence.strip,
          score: calculate_snippet_score(sentence, query_terms),
          term: 'context'
        }
      end
      
      highlights = scored_sentences.select { |s| s[:score] > 0 }
    end

    highlights.sort_by { |h| -h[:score] }
             .take(max_highlights)
             .map { |h| h[:text].truncate(snippet_length) }
             .reject(&:blank?)
             .presence || [content_preview(snippet_length)]
  end

  private

  def calculate_snippet_score(text, query_terms)
    text_lower = text.downcase
    score = 0
    
    query_terms.each do |term|
      term_count = text_lower.scan(term.downcase).length
      score += term_count * 10
      
      if text_lower.include?(term.downcase)
        score += 5
      end
    end
    
    score += text.length > 50 ? 2 : 0
    score
  end

  def strip_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end
end