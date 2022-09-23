class CreateTweet < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :username
    end
    
    create_table :tweets do |t|
      t.string :content
      t.integer :user_id
      t.timestamps
    end
  end
end
