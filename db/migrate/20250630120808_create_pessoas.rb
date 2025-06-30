class CreatePessoas < ActiveRecord::Migration[8.0]
  def change
    create_table :pessoas, id: false do |t|
      t.string :email, primary_key: true
      t.string :nome
      t.string :matricula
      t.string :senha

      t.timestamps
    end
  end
end
