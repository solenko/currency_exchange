require 'rails_helper'

describe ExchangeRateConverter do
  let(:date) { Date.today - rand(10).days }
  let(:amount) { rand(100) }
  let(:rate) { rand }
  subject { ExchangeRateConverter.new(amount, date) }

  describe '.convert' do

    it 'instantiate converter instance' do
      instance = double('ExchangeRateConverter').as_null_object
      expect(ExchangeRateConverter).to receive(:new).with(amount, date).and_return(instance)
      ExchangeRateConverter.convert(amount, date.to_s)
    end

    it 'convert amount it usd' do
      instance = double('ExchangeRateConverter')
      expect(instance).to receive(:to_usd)
      allow(ExchangeRateConverter).to receive(:new).and_return(instance)
      ExchangeRateConverter.convert(amount, date.to_s)
    end
  end

  describe '#rate' do
    it 'fetch rate from database' do
      expect(ExchangeRate).to receive(:for_date).with(date) { ExchangeRate.new(rate: rate) }
      expect(subject.rate).to be_within(0.001).of(rate)
    end

    it 'raise error if rate not exists in database' do
      allow(ExchangeRate).to receive(:for_date) { nil }
      expect { subject.rate }.to raise_error(ExchangeRateConverter::NoExchangeRate)

    end
  end

  describe '#to_usd' do
    it 'calculate usd value based on rate' do
      expect(subject).to receive(:rate).and_return(rate)
      expect(subject.to_usd).to be_within(0.001).of(amount * rate)
    end
  end
end


