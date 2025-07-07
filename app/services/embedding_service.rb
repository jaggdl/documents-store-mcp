require "net/http"
require "json"

class EmbeddingService
  EMBEDDING_SERVICE_URL = ENV.fetch("EMBEDDING_SERVICE_URL", "http://localhost:5001")

  def self.generate_embeddings(texts)
    uri = URI("#{EMBEDDING_SERVICE_URL}/embed")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { texts: texts }.to_json

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
    else
      raise "Embedding service error: #{response.code} - #{response.body}"
    end
  end

  def self.generate_embedding(text)
    result = generate_embeddings([ text ])
    result["embeddings"].first
  end

  def self.cosine_similarity(embedding1, embedding2)
    return 0.0 if embedding1.nil? || embedding2.nil?

    dot_product = embedding1.zip(embedding2).sum { |a, b| a * b }
    magnitude1 = Math.sqrt(embedding1.sum { |a| a * a })
    magnitude2 = Math.sqrt(embedding2.sum { |a| a * a })

    return 0.0 if magnitude1 == 0 || magnitude2 == 0

    dot_product / (magnitude1 * magnitude2)
  end
end

