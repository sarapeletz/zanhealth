class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :encrypted_password
      t.integer :role_id
      t.datetime :created
      t.datetime :modified
      t.integer :telephone_num

      t.timestamps
    end
  end
end
