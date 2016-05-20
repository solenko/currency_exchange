class ExchangeRateConverter
  class NoExchangeRate < StandardError ; end

  attr_reader :euros
  attr_reader :date

  class << self
    def convert(amount, date_string)
      date = Date.parse(date_string)
      new(amount, date).to_usd
    end
  end

  def initialize(amount, date = Date.today)
    @euros, @date = amount, date
  end

  def to_usd
    euros * rate
  end

  def rate
    @rate ||= (ExchangeRate.for_date(date) || raise(NoExchangeRate)).rate
  end
end