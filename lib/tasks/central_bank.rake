namespace :central_bank do
  desc 'Import exchange rates from Central Bank data source'
  task :import_rates => :environment do
    CentralBank::RateImporter.import
  end
end