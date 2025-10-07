class EmailParser::Supplier < EmailParser::Base
  NAME_REGEX = /^(?:Nome(?:\s+do\s+cliente)?|Nome\s+completo|Cliente)\s*:\s*([\p{L}][\p{L}\s'.-]{1,})$/imu
  EMAIL_REGEX = /^(?:E-?mail(?:\s+de\s+contato)?)\s*:\s*([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})$/i
  PHONE_REGEX = /^(?:Telefone(?:\s+de\s+contato)?)\s*:\s*([\d\s()-]{7,})$/i
  PRODUCT_CODE_LABEL_REGEX = /^(?:Produto(?:\s+de\s+interesse)?|Código\s+do\s+produto)\s*:\s*([A-Z]{2,}(?:-?\d{3,}))$/i
  PRODUCT_CODE_INLINE_REGEX = /\bproduto(?:\s+de\s+c[óo]digo)?\s+([A-Z]{2,}(?:-?\d{3,}))\b/iu

  def parse
    validate_fields

    return log_failure(log_params) unless @success

    if Customer.create(customer_params)
      log_success
    else
      @errors << "Failed to create customer record"
      log_failure(log_params)
    end
  rescue => e
    @errors << "Exception occurred: #{e.message}"
    log_failure(log_params(e))
  end

  private

  def validate_fields
    @name = extract_field(NAME_REGEX, @raw_email)
    @email = extract_field(EMAIL_REGEX, @raw_email)
    @phone = extract_field(PHONE_REGEX, @raw_email)
    @subject = extract_field(SUBJECT_REGEX, @raw_email)
    @product_code = extract_field(PRODUCT_CODE_LABEL_REGEX, @raw_email) || extract_field(PRODUCT_CODE_INLINE_REGEX, @raw_email)

    @errors << "Subject is missing" if @subject.nil?
    @errors << "Name is missing" if @name.nil?
    @errors << "Email is missing" if @email.nil?
    @errors << "Phone is missing" if @phone.nil?
    @errors << "Product code is missing" if @product_code.nil?

    @success = @errors.empty?
  end

  def customer_params
    {
      name: @name,
      email: @email,
      phone: @phone,
      product_code: @product_code,
      subject: @subject
    }
  end

  def log_params(exception = nil)
    customer_params.merge({
      errors: @errors,
      success: @success,
      exception: exception&.message
    })
  end
end
