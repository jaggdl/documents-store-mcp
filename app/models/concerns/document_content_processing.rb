module DocumentContentProcessing
  extend ActiveSupport::Concern

  def content_as_html
    html = Commonmarker.to_html(content, options: {
      parse: { smart: true }
    },
      plugins: {
        syntax_highlighter: {
          theme: "base16-ocean.dark"
        }
      },
                        )

    process_mermaid_diagrams(html).html_safe
  end

  def content_preview(length = 150)
    strip_tags(content_as_html).truncate(length)
  end

  private

  def process_mermaid_diagrams(html)
    mermaid_id = 0

    html.gsub(%r{<pre lang="mermaid"[^>]*><code>(.*?)</code></pre>}m) do |match|
      code_content = $1
      mermaid_code = strip_tags(code_content).strip
      mermaid_code = CGI.unescapeHTML(mermaid_code)
      mermaid_id += 1

      begin
        png_content = render_mermaid_to_png(mermaid_code)
        base64_png = Base64.strict_encode64(png_content)

        %(<div class="mermaid-diagram" id="mermaid-#{mermaid_id}">
          <img src="data:image/png;base64,#{base64_png}" alt="Mermaid diagram" class="max-w-full h-auto mx-auto" />
        </div>)
      rescue => e
        Rails.logger.error "Mermaid rendering error: #{e.message}"
        %(<div class="mermaid-error">Error rendering diagram: #{e.message}</div>)
      end
    end
  end

  def render_mermaid_to_png(mermaid_code)
    require "tempfile"

    # Check if mmdc is available
    unless system("which mmdc > /dev/null 2>&1")
      raise "mermaid-cli (mmdc) not found. Please install with: npm install -g @mermaid-js/mermaid-cli"
    end

    input_file = Tempfile.new([ "mermaid", ".mmd" ])
    output_file = Tempfile.new([ "mermaid", ".png" ])

    begin
      input_file.write(mermaid_code)
      input_file.close

      command = "mmdc -i #{input_file.path} -o #{output_file.path} -t neutral -b white 2>&1"
      output = `#{command}`
      result = $?.success?

      unless result
        Rails.logger.error "Mermaid CLI failed: #{output}"
        raise "Mermaid CLI command failed: #{output}"
      end

      unless File.exist?(output_file.path)
        raise "Mermaid output file not created"
      end

      File.read(output_file.path)
    ensure
      input_file.unlink if input_file
      output_file.unlink if output_file
    end
  end

  def strip_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end
end
