class ExchangeRate < ActiveRecord::Base

  self.primary_key = 'date'

  def self.for_date(date)
    where('date <= ?', date).order('date DESC').first
  end
end