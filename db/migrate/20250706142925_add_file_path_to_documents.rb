class AddFilePathToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :file_path, :string
  end
end
