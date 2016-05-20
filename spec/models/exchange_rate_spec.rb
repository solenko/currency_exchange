require 'rails_helper'

describe ExchangeRate do
  describe '.for_date' do
    let!(:last_rate){ ExchangeRate.create!(date: '2016-05-22', rate: 3) }
    let!(:earlier_rate){ ExchangeRate.create!(date: '2016-05-18', rate: 2) }
    let!(:middle_rate){ ExchangeRate.create!(date: '2016-05-20', rate: 1) }

    it 'select rate for given date if exists' do
      expect(ExchangeRate.for_date(middle_rate.date).date).to eq(middle_rate.date)
    end

    it 'select nearest prior rate if exact date not found' do
      expect(ExchangeRate.for_date(last_rate.date - 1.day).date).to eq(middle_rate.date)
    end

    it 'return nil if earlier exchange rate not found' do
      expect(ExchangeRate.for_date(earlier_rate.date - 1.day)).to be_nil
    end
  end
end