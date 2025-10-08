module ParserLogger
  def log_failure(log_params)
    persist_log(log_params, success: false)
  end

  def log_success(log_params)
    persist_log(log_params, success: true)
  end

  private

  def persist_log(log_params, success:)
    attrs = formatted_params(log_params)
    if @log
      @log.update!(attrs)
    else
      log = Log.create!(attrs)
      log.eml_file.attach(file_params(@raw_email))
    end
  end

  def formatted_params(log_params)
    {
      extracted_info: log_params[:customer_params],
      errors_info: log_params[:errors_info],
      status: log_params[:success] ? Log.statuses[:success] : Log.statuses[:failure]
    }
  end

  def file_params(raw_email)
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    {
      io: StringIO.new(raw_email),
      filename: "email_#{timestamp}.eml",
      content_type: "message/rfc822"
    }
  end
end
