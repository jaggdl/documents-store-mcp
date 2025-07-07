class CreateProjectVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :project_vectors do |t|
      t.references :project, null: false, foreign_key: true
      t.vector :embedding, limit: 768
      t.timestamps
    end
  end
end
