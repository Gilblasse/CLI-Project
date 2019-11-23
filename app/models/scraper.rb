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
		movie_obj.directors = details.css('.credit_summary_item').first.css('a').text.split(",")
		movie_obj.stars = details.css('.credit_summary_item')[2].text.strip.split(/[,|:\n]/)[2...-2].map{|e|e.strip}
		movie_obj.subtext = subtext.css('.subtext').text.split(/[|]/).map{|e| e.strip}.join(" | ").gsub(/\n/,"")
		movie_obj
	end

end