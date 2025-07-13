class CreateCargos < ActiveRecord::Migration[8.0]
   def change
    execute <<-SQL
      CREATE TABLE cargos (
        email TEXT NOT NULL,
        funcao TEXT NOT NULL,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (email, funcao),
        FOREIGN KEY (email) REFERENCES pessoas(email)
      );
    SQL
  end
end
