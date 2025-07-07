namespace :embeddings do
  desc "Generate embeddings for all documents"
  task generate: :environment do
    puts "Generating embeddings for all documents..."
    
    documents = Document.where(embedding: [nil, ''])
    total = documents.count
    
    if total == 0
      puts "No documents need embedding generation."
      exit
    end
    
    puts "Found #{total} documents without embeddings."
    
    documents.find_each.with_index do |document, index|
      begin
        print "Processing document #{index + 1}/#{total}: #{document.title}... "
        document.generate_embedding
        puts "✓"
      rescue => e
        puts "✗ Error: #{e.message}"
      end
    end
    
    puts "Finished generating embeddings."
  end
  
  desc "Regenerate embeddings for all documents"
  task regenerate: :environment do
    puts "Regenerating embeddings for all documents..."
    
    documents = Document.all
    total = documents.count
    
    puts "Found #{total} documents."
    
    documents.find_each.with_index do |document, index|
      begin
        print "Processing document #{index + 1}/#{total}: #{document.title}... "
        document.generate_embedding
        puts "✓"
      rescue => e
        puts "✗ Error: #{e.message}"
      end
    end
    
    puts "Finished regenerating embeddings."
  end
end