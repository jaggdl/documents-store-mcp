class CreateDocumentVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :document_vectors do |t|
      t.references :document, null: false, foreign_key: true
      t.vector :embedding, limit: 768
      t.timestamps
    end
  end
end
