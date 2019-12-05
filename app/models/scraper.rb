class Scraper
	attr_accessor :imdb_url,:scraped_movies,:page,:doc

	def scrape
		@imdb_url = "https://www.imdb.com"
		html = open("#{imdb_url}#{@page}")
		@doc = Nokogiri::HTML(html)
	end

	# MOVIE PAGES SECTION
	def first_page
		@page = "/chart/top"
		scrape

		scraped_movies = @doc.css("tbody.lister-list tr")
		scraped_movies.each do |movie|
			hash = {
						title: movie.css(".titleColumn").text.split("\n")[2].strip,
						year: movie.css(".titleColumn").text.split("\n")[3].gsub(/[()\s]/,""),
						url: movie.css(".titleColumn a")[0]['href'],
						rating: movie.css(".ratingColumn").text.scan(/\d[.]\d/)[0]
					}
			Movie.new(hash)
		end
	end

	def second_page(movie)
		@page = movie.url
		scrape

		@director_section = @doc.css(".plot_summary h4 + a")[0]
		@stars_section = @doc.css('.credit_summary_item')[2].css("a")[0..-2]
		@trailer = @doc.css(".slate a")[0]["href"]

		movie.summary = @doc.css('.summary_text').text.strip
		movie.director = [@director_section.text, @director_section['href']]
		movie.stars = @stars_section.map{ |e| [ e.text,e['href'] ] }
		movie.subtext = @doc.css('.subtext').text.split(/[|]/).map{|e| e.strip}.join(" | ").gsub(/\n/,"")
		movie.trailer = "#{@imdb_url}#{@trailer}" if @trailer

		movie
	end


	# STAR SECTION
	def find_or_scrape_star(url)
		@page = url
		star = Star.find_star_by_url(@page)
		if star.nil?
			scrape

			stars_hash = stars_page_hash
			star = Star.new(stars_hash)
		end
			star
	end

	def stars_page_hash
		{
			fullname: @doc.css(".itemprop")[0].text,
			subtext: @doc.css(".itemprop")[1..-1].text.gsub(/(?!^\n)\n/," | ").gsub(/\n/,""),
			known_for: @doc.css("#knownfor .knownfor-title-role a").map{|e|e.text}
		}
		.merge(star_bio_page_hash)
	end

	def star_bio_page_hash
		@page = "#{@page}bio?ref_=nm_ov_bio_sm"
		scrape
		{
			born: @doc.css("#overviewTable tr:nth-child(1) td:nth-child(2) a").map{|e| e.text},
			bio: @doc.css(".soda p").text.split(/\n/)[1].strip,
		}
	end

	
	# SCRAPING GOSTREAM WEBSITE FOR MOVIE CLASS METHOD PLAY MOVIE
	def self.gostream_scraper(html)
		doc = Nokogiri::HTML.parse(html)
		movies_list = doc.css(".movies-list-full .ml-item")
		movies_list.map{|movie| [movie.css("a")[0]['oldtitle'],movie.css("a")[0]['href']] }.to_h
	end
end