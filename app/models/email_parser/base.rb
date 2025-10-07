class EmailParser::Base
  include Logger

  FROM_REGEX = /From:\s*(.*?)(\s|$)/i
  TO_REGEX = /To:\s*(.*?)(\s|$)/i
  SUBJECT_REGEX = /Subject:\s*(.*?)\n/i

  attr_reader :raw_email, :errors, :success

  def initialize(raw_email)
    @raw_email = raw_email
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

  private

  def extract_field(regex)
    match = @raw_email.match(regex)
    match ? match[1].strip : nil
  end
end
