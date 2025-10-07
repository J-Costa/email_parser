class Log < ApplicationRecord
  enum :status, { success: "success", failure: "failure" }

  has_one_attached :eml_file
end
