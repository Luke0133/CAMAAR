class AddUniqueConstraintToPessoasEmail < ActiveRecord::Migration[8.0]
  def change
    change_column_null :pessoas, :email, false
    add_index :pessoas, :email, unique: true, name: "index_pessoas_on_email_unique"
  end
end

