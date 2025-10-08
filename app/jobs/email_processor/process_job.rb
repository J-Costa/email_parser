class EmailProcessor::ProcessJob < ApplicationJob
  queue_as :default

  def perform(log_id)
    raw_email = Log.find(log_id).eml_file.download

    EmailParser::Processor.process(raw_email)
  end
end
