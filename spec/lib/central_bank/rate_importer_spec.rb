require 'rails_helper'

describe CentralBank::RateImporter do
  let(:filename) { "some_random_file_name_#{rand(1000)}" }
  subject { CentralBank::RateImporter }

  describe '.import' do


    it 'download csv' do
      expect(subject).to receive(:download_csv).and_return(filename)
      allow(subject).to receive(:persist)
      allow(File).to receive(:delete)
      subject.import
    end

    it 'persist data from tempfile' do
      allow(subject).to receive(:download_csv).and_return(filename)
      expect(subject).to receive(:persist).with(filename)
      allow(File).to receive(:delete)
      subject.import
    end

    it 'perform cleanup' do
      allow(subject).to receive(:download_csv).and_return(filename)
      allow(subject).to receive(:persist)
      expect(File).to receive(:delete).with(filename)
      subject.import
    end
  end

  describe '.persist' do
    let(:min_date) { Date.parse(CentralBank::RateImporter::MIN_DATE) }

    it 'skip header' do
      csv_row = ['header line']
      allow(CSV).to receive(:foreach).and_yield(csv_row)
      expect(subject).to_not receive(:persist_row)
      subject.persist('')
    end

    it 'persist each row' do
      csv_row = ['2015-01-01', '1']
      allow(CSV).to receive(:foreach).and_yield(csv_row).and_yield(csv_row)
      expect(subject).to receive(:persist_row).exactly(2).times
      subject.persist('')
    end

    it 'ignore dates bellow min date' do
      csv_row = [(min_date - 1.day).to_s, '1']
      allow(CSV).to receive(:foreach).and_yield(csv_row)
      expect(subject).to_not receive(:persist_row)
      subject.persist('')
    end
  end

  describe '.persist_row' do
    it 'create new record for given date if not exists' do
      expect {
        subject.persist_row(['2015-01-01', 1])
      }.to change { ExchangeRate.count }.by(1)
    end

    it 'update existed record if it already exists' do
      date =  '2015-01-01'

      ExchangeRate.create(date: date, rate: 1)
      expect {
        subject.persist_row([date, 2])
      }.to_not change { ExchangeRate.count }
      expect(ExchangeRate.where(date: date).first.rate).to be_within(0.001).of(2)
    end
  end

end

