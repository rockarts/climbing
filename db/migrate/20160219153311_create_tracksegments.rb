class CreateTracksegments < ActiveRecord::Migration
  def change
    create_table :tracksegments do |t|
      t.references :track, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
