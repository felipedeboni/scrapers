require 'net/http'
require 'nokogiri'
require 'open-uri'

class ScraperDollar

	@@baseUrl = "http://cotacoes.economia.uol.com.br/cambio/cotacoes-diarias.html?cod=BRL"

	def initialize
		self
	end

	def exchange_rate
		html  = Nokogiri::HTML(open(@@baseUrl))
		parse( html )
	end

	private
		def parse( doc )
			result = { :current => 0, :variation => 0 }
			
			doc.css('#main table tbody tr:first-child').each do |row|
				result[ :current ] = row.css( 'td.compra' )[0].text.strip.gsub( ',', '.' ).to_f
			end

			doc.css('#main table tbody tr:nth-child(2)').each do |row|
				result[ :variation ] = row.css( 'td.ultima' )[0].text.strip.gsub( ',', '.' ).to_f
			end
			result
		end

end