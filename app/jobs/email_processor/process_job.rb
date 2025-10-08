class EmailProcessor::ProcessJob < ApplicationJob
  queue_as :default

  def perform(log_id)
    log = Log.find(log_id)
    raw_email = log.eml_file.download

    EmailParser::Processor.process(raw_email, log: log)
  end
end
