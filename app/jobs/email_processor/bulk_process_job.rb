class EmailProcessor::BulkProcessJob < ApplicationJob
  queue_as :default

  def perform(log_ids)
    Log.where(id: log_ids).find_each do |log|
      EmailProcessor::ProcessJob.perform_later(log.id)
    end
  end
end
