class CreateParticipantes < ActiveRecord::Migration[8.0]
  def change
    create_table :participantes do |t|
      t.references :pessoa, null: false, foreign_key: true
      t.integer :id_turma, null: false
      t.timestamps
    end

    add_foreign_key :participantes, :turmas, column: :id_turma, primary_key: :id
  end
end
