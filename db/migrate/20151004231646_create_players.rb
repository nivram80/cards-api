class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :fname, null: false
      t.string :lname, null: false
      t.boolean :hall_of_fame, default: false

      t.timestamps null: false
    end
  end
end
