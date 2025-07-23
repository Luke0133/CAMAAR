class CreateCargos < ActiveRecord::Migration[8.0]
  def change
    create_table :cargos do |t|
      t.references :pessoa, null: false, foreign_key: true
      t.integer :funcao, null: false
      t.timestamps
    end

    add_index :cargos, [:email, :funcao], unique: true
  end
end
