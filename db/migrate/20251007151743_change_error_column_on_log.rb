class ChangeErrorColumnOnLog < ActiveRecord::Migration[8.0]
  def change
    rename_column :logs, :errors, :errors_info
  end
end
