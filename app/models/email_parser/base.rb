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

  attr_reader :raw_email, :errors, :success

  def initialize(raw_email)
    @raw_email = raw_email.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    @errors = []
    @success = false
  end

  def validate
    raise NotImplementedError, "#{self.class.name} must implement the #{__method__} method"
  end

  def parse
    raise NotImplementedError, "#{self.class.name} must implement the #{__method__} method"
  end

  def self.from_email(raw_email)
    raw_email.match(FROM_REGEX)&.[](1)
  end

  def extract_name
    extract_field(NAME_REGEX)
  end

  def extract_email
    extract_field(EMAIL_REGEX)
  end

  def extract_phone
    extract_field(PHONE_REGEX)
  end

  def extract_subject
    extract_field(SUBJECT_REGEX)
  end

  def extract_product_code
    extract_field(PRODUCT_CODE_LABEL_REGEX) || extract_field(PRODUCT_CODE_INLINE_REGEX)
  end

  private

  def validate_fields
    @name = extract_name
    @email = extract_email
    @raw_phone = extract_phone
    @phone = @raw_phone&.gsub(/\D/, "")
    @subject = extract_subject
    @product_code = extract_product_code

    @errors << "Subject is missing" if @subject.nil?
    @errors << "Name is missing" if @name.nil?
    @errors << "Email is missing" if @email.nil?
    @errors << "Phone is missing" if @phone.nil?
    @errors << "Product code is missing" if @product_code.nil?

    @success = @errors.empty?
  end

  def extract_field(regex)
    match = @raw_email.match(regex)
    match ? match[1].strip : nil
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
