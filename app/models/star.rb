class Star
	attr_accessor :name, :url, :bio,:summary,:subtext,:born,:known_for
	@@all = []

	def initialize(movie_hash)
		movie_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
		save
    end

    def save
        @@all << self
    end

    def all
        @@all
    end

end