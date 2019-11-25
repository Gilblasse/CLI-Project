class Movie
	attr_accessor :title, :year, :url, :rating,:summary,:director,:stars,:film_rating,:subtext,:image,:trailer,:play_movie
	@@all = []

	def initialize(movie_hash)
		movie_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
		@@all << self
	end

	def self.all
		@@all
	end

	def self.find_by_title(title)
		self.all.find {|movie| movie.title == title }
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