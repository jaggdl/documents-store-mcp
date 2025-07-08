namespace :marqo do
  desc "Sync all documents and projects to Marqo"
  task sync_all: :environment do
    marqo_service = MarqoService.new

    puts "Creating Marqo indexes..."
    marqo_service.create_indexes

    puts "Syncing #{Document.count} documents..."
    Document.find_each do |document|
      begin
        marqo_service.add_document(document)
        print "."
      rescue => e
        puts "\nError syncing document #{document.id}: #{e.message}"
      end
    end

    puts "\nSyncing #{Project.count} projects..."
    Project.find_each do |project|
      begin
        marqo_service.add_project(project)
        print "."
      rescue => e
        puts "\nError syncing project #{project.id}: #{e.message}"
      end
    end

    puts "\nSync complete!"
  end

  desc "Clear all Marqo indexes"
  task clear: :environment do
    marqo_service = MarqoService.new

    puts "Clearing Marqo indexes..."
    begin
      uri = URI("#{marqo_service.send(:instance_variable_get, :@base_url)}/indexes/#{MarqoService::DOCUMENTS_INDEX}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Delete.new(uri)
      http.request(request)

      uri = URI("#{marqo_service.send(:instance_variable_get, :@base_url)}/indexes/#{MarqoService::PROJECTS_INDEX}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Delete.new(uri)
      http.request(request)

      puts "Indexes cleared!"
    rescue => e
      puts "Error clearing indexes: #{e.message}"
    end
  end
end
