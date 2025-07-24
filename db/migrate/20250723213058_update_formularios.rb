class UpdateFormularios < ActiveRecord::Migration[8.0]
  def change
    add_column :formularios, :destino, :integer
  end
end