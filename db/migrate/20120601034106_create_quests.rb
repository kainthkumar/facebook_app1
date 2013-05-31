class CreateQuests < ActiveRecord::Migration
  def change
    create_table :quests do |t|
      t.string :name
      t.string :quest_ordering
      t.string :reward
    end
  end
end
