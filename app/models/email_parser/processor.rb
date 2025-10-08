class EmailParser::Processor
  PARSERS_MAP = {
    "fornecedor" => EmailParser::Supplier,
    "parceiro" => EmailParser::Partner
  }

  def self.process(raw_email, log: nil)
    from_email = EmailParser::Base.from_email(raw_email)&.downcase
    parser_class = PARSERS_MAP.find { |key, klass| from_email&.include?(key) }&.last

    parser = parser_class.new(raw_email, log: log)
    parser.parse
  end
end
