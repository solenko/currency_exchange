require 'tempfile'
require 'net/http'
require 'csv'

module CentralBank
  class RateImporter
    MIN_DATE = '2000-01-01'
    URL = 'http://sdw.ecb.europa.eu/export.do?node=2018794&CURRENCY=USD&SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&exportType=csv'

    class << self
      def import
        begin
        filename = download_csv
        begin
          persist(filename)
        ensure
          File.delete(filename)
        end
        rescue => e
          log_error(e)
        end
      end

      def download_csv
        f = Tempfile.new('central_bank')
        begin
          uri = URI(URL)
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Get.new uri
            http.request(request) do |response|
              response.read_body do |segment|
                f.write(segment)
              end
            end

          end
        ensure
          f.close()
        end
        f.path
      end

      def persist(filename)
        # We use trusted source so ignore malformed CSV errors
        # If this kind of errors occurs, most possible reason is a network errors
        CSV.foreach(filename, headers: false) do |row|
          next if header_line? row
          # CSV file ordered by date DESC and we don't need date earlier than MIN_DATE
          break if row.first < MIN_DATE
          persist_row(row)
        end
      end

      def persist_row(csv_row)
        # we don't have alot of data to save, so can avoid batch inserts and use naive upsert
        date = Date.parse(csv_row.first)
        rate = ExchangeRate.where(date: date).first_or_initialize
        rate.rate = csv_row.last.to_f
        rate.save!
      end

      private

      def header_line?(csv_row)
        !(csv_row.first =~ /\A\d{4}-\d{2}-\d{2}\z/)
      end



      def log(message, severity = Logger::DEBUG)
        Rails.logger.log(severity, message)
      end

      def log_error(exception)
        log(exception.message + "\n" + exception.backtrace.join("\n"))

      end
    end
  end
end