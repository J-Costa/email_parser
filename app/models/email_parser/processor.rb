class EmailParser::Processor
  PARSERS_MAP = {
    "fornecedor" => EmailParser::Supplier,
    "parceiro" => EmailParser::Partner
  }

  class << self
    def process(raw_email, log: nil)
      from_email = EmailParser::Base.extract_from_email_address(raw_email)&.downcase
      parser_class = PARSERS_MAP.find { |key, klass| from_email&.include?(key) }&.last
      parser_class ||= EmailParser::NullParser

      parser = parser_class.new(raw_email, log: log)
      parser.parse
    end
  end
end
