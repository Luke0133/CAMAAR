class CreateParticipantes < ActiveRecord::Migration[8.0]
  def change
    execute <<-SQL
      CREATE TABLE participantes (
        email TEXT NOT NULL,
        id_turma INTEGER NOT NULL,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (email, id_turma),
        FOREIGN KEY (email) REFERENCES pessoas(email),
        FOREIGN KEY (id_turma) REFERENCES turmas(id)
      );
    SQL
  end
end
