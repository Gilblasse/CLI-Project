class Movie
	extend Memorable::ClassMethods
	include Memorable::InstanceMethods
	include Connect
	attr_accessor :title, :year, :url, :rating,:summary,:director,:stars,:film_rating,:subtext,:trailer,:play_movie
	FONT_Style_A = Artii::Base.new :font => 'cricket'
	FONT_STYLE = Artii::Base.new :font => 'cursive'
	@@all = []

	def initialize(movie_hash)
		movie_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
		save
	end

	def stars
		roles.map{|role| role.star}
	end

	def director
		roles.map{|role| role.director}.uniq
	end

	def get_selected_movie
		gostream_site = "gostream.site"
		browser = Watir::Browser.new(:chrome, {:chromeOptions => {:args => ['--headless', '--window-size=1200x600']}})
		browser.goto gostream_site
		browser.text_field(placeholder: "Search..").set self.title
		browser.button(type: "submit").click
		movies = Scraper.gostream_scraper(browser.html)
		movies[self.title]
	end

	def play_movie_w_message
		movie_url = self.get_selected_movie
		Launchy.open(movie_url) if movie_url
		movie_url ? FONT_Style_A.asciify("Playing Movie") : FONT_Style_A.asciify("Sorry Movie Not Available!!")
	end


	def play_trailer_w_message
		Launchy.open(self.trailer) if self.trailer
		self.trailer ? FONT_Style_A.asciify("Playing Trailer") : FONT_Style_A.asciify("Sorry Trailer Not Available")
	end

	def display_movie_info
		[
			"#{FONT_STYLE.asciify(self.title)}\n",
			"\n#{self.title.upcase}\n#{self.subtext}",
			"\n#{"Summary:".magenta} #{self.summary}\n",
			"#{"Top 3 Actors:".magenta} #{self.stars.map {|star| star.fullname }.join(', ')}",
			"#{"Directors:".magenta} #{self.director.first.fullname}"
		]
	end


	def self.matching_titles
		title = gets.chomp
		cli = Top250MoviesEver::CLI.new
		cli.menu_a if title.eql? 'q'
		white = Text::WhiteSimilarity.new
		matching_movies = self.all.select {|movie| white.similarity(movie.title, title) >= 0.3}
		matching_movies.empty? ? -> { cli.print_center(self.not_found) } : matching_movies
	end

	def self.not_found
		[
			"!! Sorry... Movie Not Found in IMDB Top 250 List !!\n",
			"Please Try Again.  ☹"
		]
	end

	def self.all
		@@all
	end

	def self.find_by_year(input)
		self.all.select {|movie| movie.year.to_i == input}
	end

	def self.sort_by_highest_ratings
		self.all.sort{|m_a,m_b| m_b.rating.to_f <=> m_a.rating.to_f}
	end

	def self.sort_by_lowest_ratings
		self.all.sort{|m_a,m_b| m_a.rating.to_f <=> m_b.rating.to_f}
	end

	def self.sort_by_alphabetical_order
		self.all.sort{|m_a,m_b| m_a.title <=> m_b.title}
	end

	def self.sort_by_year
		self.all.sort{|m_a,m_b| m_b.year <=> m_a.year}
	end

	
end