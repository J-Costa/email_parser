class EmailParser::Base
  include ParserLogger

  FROM_REGEX = /From:\s*(.*?)(\s|$)/i
  TO_REGEX = /To:\s*(.*?)(\s|$)/i
  SUBJECT_REGEX = /Subject:\s*(.*?)\n/i

  NAME_REGEX = /^(?:Nome(?:\s+do\s+cliente)?|Nome\s+completo|Cliente)\s*:\s*([\p{L}][\p{L}\s'.-]{1,})$/imu
  EMAIL_REGEX = /^(?:E-?mail(?:\s+de\s+contato)?)\s*:\s*([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})$/i
  PHONE_REGEX = /^(?:Telefone(?:\s+de\s+contato)?)\s*:\s*((?:\+\d{1,3}\s*)?[\d\s()\-]{7,})$/i
  PRODUCT_CODE_LABEL_REGEX = /^(?:Produto(?:\s+de\s+interesse)?|Código\s+do\s+produto)\s*:\s*([A-Z]{2,}(?:-?\d{3,}))$/i
  PRODUCT_CODE_INLINE_REGEX = /\bproduto(?:\s+de\s+c[óo]digo)?\s+([A-Z]{2,}(?:-?\d{3,}))\b/iu

  class << self
    def extract_from_email_address(raw_email)
      raw_email.match(FROM_REGEX)&.captures&.first&.strip
    end
  end

  attr_reader :raw_email, :log, :errors, :success

  def initialize(raw_email, log: nil)
    @raw_email = raw_email.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    @log = log
    @errors = []
    @success = false
  end

  def parse
    set_fields
    validate_fields

    return log_failure(log_params) unless @success

    customer = Customer.new(customer_params)
    if customer.save
      log_success(log_params)
    else
      @errors << "Failed to create customer record"
      @errors << customer.errors.full_messages
      @success = false
      log_failure(log_params)
    end
  rescue => e
    @errors << "Exception occurred: #{e.message}"
    log_failure(log_params(e))
  end

  private

  def set_fields
    @name = extract_name
    @email = extract_email
    @phone = extract_phone
    @subject = extract_subject
    @product_code = extract_product_code
  end

  def extract_name
    extract_field(NAME_REGEX)
  end

  def extract_email
    extract_field(EMAIL_REGEX)
  end

  def extract_phone
    raw_phone = extract_field(PHONE_REGEX)
    raw_phone&.gsub(/\D/, "")
  end

  def extract_subject
    extract_field(SUBJECT_REGEX)
  end

  def extract_product_code
    extract_field(PRODUCT_CODE_LABEL_REGEX) || extract_field(PRODUCT_CODE_INLINE_REGEX)
  end

  def extract_field(regex)
    @raw_email.match(regex)&.captures&.first&.strip
  end

  def validate_fields
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
      email_subject: @subject
    }
  end

  def log_params(exception = nil)
    base_params = {
      customer_params: customer_params,
      errors_info: {},
      success: @success
    }
    if exception || @errors.any?
      base_params[:errors_info] = { errors: @errors,
        exception: exception&.message,
        backtrace: exception&.backtrace }
      base_params[:success] = false
    else
      base_params[:success] = true
    end
    base_params
  end
end
