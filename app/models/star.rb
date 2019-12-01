class Star
	attr_accessor :fullname, :url, :bio,:summary,:subtext,:born,:known_for
	@@all = []

	def initialize(movie_hash)
		movie_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
		save
    end

    def bio 
        @bio.gsub(/\.(?=(?:[^.]*\.[^.]*\.[^.]*\.[^.]*\.[^.]*\.)*[^.]*$)/,".\n\n     ")
    end

    def first_name
        fullname.split(" ").first
    end

    def last_name
        fullname.split(" ").last
    end

    def save
        @@all << self
    end

    def self.find_star_by_url(url)
        self.all.find {|star| star.url == url}
    end

    def self.all
        @@all
    end

end