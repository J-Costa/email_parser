class Log < ApplicationRecord
  enum :status, { pending: "pending", success: "success", failure: "failure" }

  has_one_attached :eml_file
end
