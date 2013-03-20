require 'net/http'
require 'nokogiri'
require 'mechanize'

class ScraperConfluence

	@@urls = {
		:login => '/login.action',
		:dash => '/dashboard.action'
	}

	def initialize( user, pass, confluence_path )
		@user = user
		@pass = pass
		@confluence_path = confluence_path

		@m = Mechanize.new
		self
	end

	def recently_updated
		login unless isLogged

		updates = []

		@m.get( get_url(@@urls[ :dash ]) ) do |p|
			doc = Nokogiri::HTML( p.content )

			doc.css( 'div.recently-updated.recently-updated-social:nth-child(2) ul.update-groupings > li.grouping' ).each do |feed|
				updates.push({
					:author => feed.css( 'h3 a.confluence-userlink' )[0].text.strip,
					:text => feed.css( 'span.update-item-content' )[0].text.strip,
					:time => feed.css( 'span.update-item-date' )[0].text.strip
				})
			end
		end

		updates
	end

	private

		def isLogged
			response = Net::HTTP.get_response URI.parse(get_url(@@urls[ :dash ]))
			response.code == '200'
		end

		def login
			@m.get( get_url(@@urls[ :login ]) ) do |lp|

				lp.form_with( :name => 'loginform' ) do |f|
				    f.field_with( :id => 'os_username' ).value = @user
				    f.field_with( :id => 'os_password' ).value = @pass
				end.click_button

			end
		end

		def get_url( path )
			"#{@confluence_path}#{path}"
		end

end