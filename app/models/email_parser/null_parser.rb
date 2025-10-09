class EmailParser::NullParser < EmailParser::Base
  def parse
    @errors << "Unsupported sender or could not determine parser"
    log_failure(log_params)
  end
end
