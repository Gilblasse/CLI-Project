require_relative "./star.rb"
class Director < Star
    @@directors = []
    
    def self.all
        @@directors
    end
end