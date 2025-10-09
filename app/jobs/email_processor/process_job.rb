class EmailProcessor::ProcessJob < ApplicationJob
  queue_as :default

  sidekiq_retries_exhausted do |job, exception|
    log_id = job.dig("args", 0, "arguments", 0)
    log = Log.find_by(id: log_id) || Log.new

    log.update!(
      status: Log.statuses[:failure],
      errors_info: {
        errors: [ "Job failed after maximum retries" ],
        exception: exception.message,
        backtrace: exception.backtrace
      }
    )
  end

  def perform(log_id)
    log = Log.find(log_id)
    raw_email = log.eml_file.download

    EmailParser::Processor.process(raw_email, log: log)
  end
end
