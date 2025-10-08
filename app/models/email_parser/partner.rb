class EmailParser::Partner < EmailParser::Base
  def parse
    set_fields
    validate_fields

    return log_failure(log_params) unless @success

    if Customer.create(customer_params)
      log_success(log_params)
    else
      @errors << "Failed to create customer record"
      log_failure(log_params)
    end
  rescue => e
    @errors << "Exception occurred: #{e.message}"
    log_failure(log_params(e))
  end
end
