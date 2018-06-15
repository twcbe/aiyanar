class CreateAccessLogs < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE direction AS ENUM ('enter', 'exit');
    SQL

    create_table :access_logs do |t|
      t.references :lock, foreign_key: true, null: false
      t.string :card_number, null: false
      t.references :user, foreign_key: true
      t.column :direction, :direction, null: false
      t.boolean :access_provided, null: false

      t.timestamps
    end
  end

  def down
    drop_table :access_logs

    execute <<-SQL
      DROP TYPE direction;
    SQL
  end
end
