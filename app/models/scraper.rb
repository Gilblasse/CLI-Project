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

	def second_page(movie) # selected movie
		@movie = movie 
		@page = movie.url
		scrape

		@director_section = @doc.css(".plot_summary h4 + a")[0]
		@stars_section = @doc.css('.credit_summary_item')[2].css("a")[0..-2]
		@trailer = @doc.css(".slate a")[0]["href"]
		
		scrape_stars_and_director
		update_movie
		create_roles
		
		@movie
	end

	def scrape_stars_and_director
		@stars = @stars_section.map {|s| Star.new({fullname: s.text, url: s['href']}) }
		@director = Director.new(fullname: @director_section.text, url: @director_section['href'])
	end
	
	def update_movie
		@movie.summary = @doc.css('.summary_text').text.strip
		@movie.subtext = @doc.css('.subtext').text.split(/[|]/).map{|e| e.strip}.join(" | ").gsub(/\n/,"")
		@movie.trailer = "#{@imdb_url}#{@trailer}" if @trailer
	end

	def create_roles
		@stars.each{|star| Role.new(star,@director,@movie) }
		# binding.pry
	end






	# STAR SECTION
	def find_and_scrape_person(url)
		@page = url

		person = Star.find_star_by_url(@page) || Director.find_star_by_url(@page)
		scrape

		person.update_info(person_page_hash)
		
		person
	end

	def person_page_hash
		{
			fullname: @doc.css(".itemprop")[0].text,
			subtext: @doc.css(".itemprop")[1..-1].text.gsub(/(?!^\n)\n/," | ").gsub(/\n/,""),
			known_for: @doc.css("#knownfor .knownfor-title-role a").map{|e|e.text}
		}
		.merge(person_bio_page_hash)
	end

	def person_bio_page_hash
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