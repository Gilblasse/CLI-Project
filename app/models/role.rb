class Role
    attr_accessor :star, :director, :movie
    @@all = []

    def initialize(star,director,movie)
            @star = star
            @director = director
            @movie = movie
            save
    end

    def save
        @@all << self
    end

    def self.all
        @@all
    end
end