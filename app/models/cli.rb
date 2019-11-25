class CLI
	BASE_PATH = "https://www.imdb.com/chart/top"

	def run
		puts File.open("imdb.txt", "r").read
		Scraper.new(BASE_PATH)
	end

	def menu
		options = %w(Movies_List Search)
		puts "                     --------------------------------"
		puts "                      #{options.map.with_index{|option,i| "#{"#{i+1}".cyan}. #{option.cyan}" }.join(" | ")}"
		puts "                     --------------------------------"
		menu_switch
	end

	def selected_movie_menu(movie)
		options = %w(Trailer Movie Actors Director)
		puts "\nChoose an Option Below"
		puts "-------------------------------------------------"
		puts options.map.with_index{|option,i| "#{"#{i+1}".cyan}. #{option.cyan}" }.join(" | ")
		puts "-------------------------------------------------"
		selected_movie_menu_switch(movie)
	end

	def selected_movie_menu_switch(movie)
		input = gets.chomp.to_i
		case input
			when 1
				puts movie.trailer
			when 2
				puts movie.play_movie
			when 3
				display_stars(movie)
			when 4
				director = Scraper.start_scraping_stars(movie.director.last)
				display_star(director)
		end
	end

	def menu_switch
		input = gets.chomp.to_i
		case input
			when 1
			display_all_movies
		end
	end
	
	def make_index
		input = gets.chomp
		input.to_i - 1
	end

	def display_all_movies
		Movie.all.each_with_index do |movie,i| 
			puts "#{i+1}. #{movie.title} ------ (#{movie.year})"
		end
		display_selected_movie
	end

	def display_selected_movie
		movie = Scraper.movie_details(selected_movie)
		puts "
		★ ★ ★ ★ ★ ★ ★ ★ ★  IMBD TV ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
				#{File.open("video.txt", "r").read}
		★ ★ ★ ★ ★ ★ ★ ★ ★  IMBD TV  ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
			"
		puts "\n#{movie.title.upcase}"
		puts movie.subtext
		puts "\n#{"Summary:".magenta} #{movie.summary}"
		puts "#{"Top 3 Actors:".magenta} #{movie.stars.map{|e|e[0]}.join(", ")}"
		puts "#{"Directors:".magenta} #{movie.director.first}"
		selected_movie_menu(movie)
	end

	def selected_movie
		input = make_index
		Movie.all[input] if input.between?(0,Movie.all.size)
	end

	def display_stars(movie)
		puts
		movie.stars.each_with_index{|e,i| puts "#{i+1}. #{e.first}"}
		selected_star(movie)
	end
	
	def selected_star(movie)
		input = make_index
		star = Scraper.start_scraping_stars(movie.stars[input][1])
		display_star(star)
	end

	def display_star(star)
		puts "\n#{star.name.upcase}"
		puts star.subtext
		puts "#{"Born:".magenta} #{star.born.first(2).join(", ")} In #{star.born.last}"
		puts "\n#{"Biography:".magenta} "
		puts star.bio.gsub(/\.(?=(?:[^.]*\.[^.]*\.[^.]*\.[^.]*\.[^.]*\.)*[^.]*$)/,".\n\n     ")
		puts "\n#{"Known For:".magenta} #{star.known_for.join(", ")}"
	end

end