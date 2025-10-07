class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_enum :log_status, [ "success", "failure" ]

    create_table :logs do |t|
      t.enum :status, enum_type: "log_status", default: "failure", null: false
      t.jsonb :errors, default: {}
      t.jsonb :extracted_info, default: {}

      t.timestamps
    end
  end
end
