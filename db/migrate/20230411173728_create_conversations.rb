class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.text :prompt
      t.text :response

      t.timestamps
    end
  end
end
