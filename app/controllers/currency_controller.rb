class CurrencyController < ApplicationController


  def exchange
    @amount = (params[:amount] || 1).to_f
    @date = Date.parse(params[:date]) rescue Date.today
    @usd = ExchangeRateConverter.convert(@amount, @date.to_s)
  end
end