class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates, id: false, primary_key: :date do |t|
      t.date :date, null: false
      t.decimal :rate, :precision => 6, :scale => 6, null: false
    end
  end
end
