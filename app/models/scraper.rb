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
		self.update_movie_attr(movie_obj,movie_details,movie_subtext,doc_bio)
	end
	
	def self.update_movie_attr(movie_obj,details,subtext,doc_bio)
		movie_obj.summary = details.css('.summary_text').text.strip
		movie_obj.director = [details.css('.credit_summary_item h4 + a')[0].text].push(
			details.css('.credit_summary_item h4 + a')[0]['href']
		)
		movie_obj.stars = details.css('.credit_summary_item')[2].css("a")[0...-1].map{|e|e.text}.zip(
			details.css('.credit_summary_item')[2].css("a")[0...-1].map{|e|e['href']}
		)
		movie_obj.subtext = subtext.css('.subtext').text.split(/[|]/).map{|e| e.strip}.join(" | ").gsub(/\n/,"")
		movie_obj.image = doc_bio.css("#title-overview-widget .slate_wrapper .poster a img")[0]['src']
		movie_obj.trailer = "https://www.imdb.com#{doc_bio.css("#title-overview-widget .slate a")[0]["href"]}"
		movie_obj.play_movie = "► https://gostream.site/#{movie_obj.title.gsub(" ","-").downcase}"
		movie_obj
	end

	def self.start_scraping_stars(url)
			html = open("https://www.imdb.com#{url}")
			doc = Nokogiri::HTML(html)
			self.initialize_star(doc,url)
	end

	def self.bio_scraper(url)
		html = open("https://www.imdb.com#{url}bio?ref_=nm_ov_bio_sm")
		doc = Nokogiri::HTML(html)
	end

	def self.generate_stars_hash(doc,url)
		bio = self.bio_scraper(url)
		{
			name: doc.css(".itemprop")[0].text,
			subtext: doc.css(".itemprop")[1..-1].text.gsub(/(?!^\n)\n/," | ").gsub(/\n/,""),
			born: bio.css("#overviewTable tr:nth-child(1) td:nth-child(2) a").map{|e| e.text},
			bio: bio.css(".soda p").text.split(/\n/)[1].strip,
			known_for: doc.css("#knownfor .knownfor-title-role a").map{|e|e.text}
		}
	end

	def self.initialize_star(doc,url)
		stars_hash = self.generate_stars_hash(doc,url)
		star = Star.new(stars_hash)
		star
	end
end