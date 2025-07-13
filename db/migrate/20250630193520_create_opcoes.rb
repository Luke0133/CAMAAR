class CreateOpcoes < ActiveRecord::Migration[8.0]
  def change
    execute <<-SQL
      CREATE TABLE opcoes (
        pergunta_id INTEGER NOT NULL,
        item INTEGER NOT NULL,
        opcao TEXT NOT NULL,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (pergunta_id, item),
        FOREIGN KEY (pergunta_id) REFERENCES perguntas(id)
      );
    SQL
  end
end


