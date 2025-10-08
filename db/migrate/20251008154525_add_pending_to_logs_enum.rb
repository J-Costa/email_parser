class AddPendingToLogsEnum < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_enum_value :log_status, 'pending'
    change_column_default :logs, :status, from: 'failure', to: 'pending'
  end
end
