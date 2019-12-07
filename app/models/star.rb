class Star
    extend Memorable::ClassMethods
    include Memorable::InstanceMethods
    include Connect
	attr_accessor :fullname, :url, :bio,:summary,:subtext,:born,:known_for
	@@all = []

    def initialize(star_hash)
		star_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
		save
    end

    def bio 
        @bio.gsub(/\.(?=(?:[^.]*\.[^.]*\.[^.]*\.[^.]*\.[^.]*\.)*[^.]*$)/,".\n\n     ") if !@bio.nil?
    end

    def display_info
        [
            "\n#{self.fullname.upcase}\n#{self.subtext}\n",
            "#{"Born:".magenta} #{self.born.first(2).join(", ")} In #{self.born.last}\n",
            "\n#{"Biography:".magenta}\n",
            "#{self.bio}\n",
            "#{"Known For:".magenta} #{self.known_for.join(", ")}"
        ]
    end

    # constructor for updating instance data
    def update_info(update_attr_hash)
        update_attr_hash.each do |k,v| 
			self.send("#{k}=",v)
		end
    end

    def movies
		roles.map{|role| role.movie}.uniq
	end

    def first_name
        fullname.split(" ").first
    end

    def last_name
        fullname.split(" ").last
    end

    def self.find_star_by_url(url)
        self.all.find {|star| star.url == url}
    end

    def self.all
        @@all
    end

end