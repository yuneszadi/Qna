class AddVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.integer :value
      t.references :user, foreign_key: true
      t.references :votable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
