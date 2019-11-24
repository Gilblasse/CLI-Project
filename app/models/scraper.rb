class Scraper

	def initialize(url)
		html = open(url)
		doc = Nokogiri::HTML(html)
		movies_list = doc.css("#main div.lister tbody.lister-list tr")
		initialize_movies(movies_list)
	end  

	def generate_movie_hash(movies)
		movies.map do |movie| 
		{
			title: movie.css(".titleColumn").text.split("\n")[2].strip,
			year: movie.css(".titleColumn").text.split("\n")[3].gsub(/[()\s]/,""),
			url: movie.css(".titleColumn a")[0]['href'],
			rating: movie.css(".ratingColumn").text.scan(/\d[.]\d/)[0]
		}
		end
	end

	def initialize_movies(movies)
		movies_obj = generate_movie_hash(movies)
		movies_obj.each do |movie_obj|
			movie = Movie.new(movie_obj)
		end
	end

	def self.movie_details(movie_obj)
		html_bio = open("https://www.imdb.com"+ movie_obj.url)
		doc_bio = Nokogiri::HTML(html_bio)
		movie_details = doc_bio.css("#title-overview-widget div.plot_summary")
		movie_subtext = doc_bio.css("#title-overview-widget .titleBar")
		self.update_movie_attr(movie_obj,movie_details,movie_subtext)
	end
	
	def self.update_movie_attr(movie_obj,details,subtext)
		movie_obj.summary = details.css('.summary_text').text.strip
		movie_obj.directors = details.css('.credit_summary_item h4 + a')[0].text
		movie_obj.stars = details.css('.credit_summary_item')[2].css("a")[0...-1].map{|e|e.text}.zip(
			details.css('.credit_summary_item a').map{|e| e['href']}[0...-1]
		)
		movie_obj.subtext = subtext.css('.subtext').text.split(/[|]/).map{|e| e.strip}.join(" | ").gsub(/\n/,"")
		# binding.pry
		movie_obj
	end

	def self.start_scraping_stars(url)
			html = open("https://www.imdb.com#{url}")
			doc = Nokogiri::HTML(html)
			self.initialize_star(doc)
	end

	def self.generate_stars_hash(doc)
		{
			name: doc.css(".itemprop")[0].text,
			subtext: doc.css(".itemprop")[1..-1].text.gsub(/(?!^\n)\n/," | ")
		}
	end

	def self.initialize_star(doc)
		stars_hash = self.generate_stars_hash(doc)
		star = Star.new(stars_hash)
		star
	end

end