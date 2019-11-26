class CLI
	BASE_PATH = "https://www.imdb.com/chart/top"
	FONT_A = Artii::Base.new :font => 'cricket'
	FONT_B = Artii::Base.new :font => 'cursive'
	OPTIONS_A = %w(Movies_List Search Quit)
	OPTIONS_B = %w(Menu Trailer Movie Actors Director Quit)
	MENU_A = "                       			    	    -------------------------------------------
								#{OPTIONS_A.map.with_index{|option,i| "#{"#{i+1}".cyan}. #{option.cyan}" }.join(" | ")}
							     -------------------------------------------"
	MENU_B = "\n						   Please Choose an Option Below
				--------------------------------------------------------------------
				#{OPTIONS_B.map.with_index{|option,i| "#{"#{i+1}".cyan}. #{option.cyan}" }.join(" | ")}
				--------------------------------------------------------------------
			"
	NOT_FOUND = "
	!! Sorry... Movie Not Found in IMDB Top 250 List !!
			Please Try Again.  ☹
	==================================================
	"


	def run
		Scraper.new(BASE_PATH)
		menu
	end

	def menu
		puts "#{File.open("imdb.txt").read}\n #{MENU_A}"
		menu_switch
	end

	def menu_switch
		input = gets.chomp
		case input
			when "1"
				display_all_movies
			when "2"
				search
			when "3","q"
				puts "Quit"
			else
				menu
		end
	end

	def search
		print "Search By Movie Title: "
		input = gets.chomp
		movies = Movie.find_by_title(input)
		display_movie_options(movies)
	end

	def display_movie_options(movies)
		if !movies.empty?
			movies.each_with_index {|movie,i| puts "#{i+1}. #{movie.title}"}
			movie = Scraper.movie_details(selected_movie(movies))
			display_selected_movie(movie)
		else
			puts NOT_FOUND
			input == "q" || input == "3"? menu : search
		end
	end

	def selected_movie_menu(movie)
		puts MENU_B
		selected_movie_menu_switch(movie)
	end

	def selected_movie_menu_switch(movie)
		input = gets.chomp
		case input
			when "1"
				menu
			when "2"
				play_trailer(movie)
			when "3"
				play_movie(movie)
			when "4"
				display_stars(movie)
			when "5"
				display_director(movie)
			when "6", "q"
				puts "Quit"
			else
				selected_movie_menu(movie)
		end
	end
	
	def play_trailer(movie)
		Launchy.open(movie.trailer) if movie.trailer
		puts movie.trailer ? FONT_A.asciify("Playing Trailer") : FONT_A.asciify("Sorry Trailer Not Available")
		selected_movie_menu(movie)
	end

	def play_movie(movie)
		Launchy.open(movie.play_movie)
		puts FONT_A.asciify("Play Movie")
		selected_movie_menu(movie)
	end

	def make_index
		input = gets.chomp.to_i
		new_input = input.abs - 1
		input.nonzero? ? new_input : menu
	end

	def display_all_movies
		Movie.all.each_with_index do |movie,i| 
			puts "#{i+1}. #{movie.title} ------ (#{movie.year})"
		end
		display_selected_movie(Scraper.movie_details(selected_movie))
	end

	def display_selected_movie(movie)
		puts "#{FONT_B.asciify(movie.title)}\n\n#{movie.title.upcase}\n#{movie.subtext}"
		puts "\n#{"Summary:".magenta} #{movie.summary}\n#{"Top 3 Actors:".magenta} #{movie.stars.map{|e|e[0]}.join(", ")}"
		puts "#{"Directors:".magenta} #{movie.director.first}"
		selected_movie_menu(movie)
	end

	def selected_movie(movie=nil)
		input = make_index
		if movie.nil? 
			input.between?(0,Movie.all.size) ? Movie.all[input] : menu
		else
			input.between?(0,movie.size) ? movie[input] : menu
		end
	end

	def display_director(movie)
		director = Scraper.start_scraping_stars(movie.director.last)
		display_star(director)
		selected_movie_menu(movie)
	end
	def display_stars(movie)
		"\n#{movie.stars.each_with_index{|e,i| puts "#{i+1}. #{e.first}"}}"
		selected_star(movie)
		selected_movie_menu(movie)
	end
	
	def selected_star(movie)
		input = make_index
		star = Scraper.start_scraping_stars(movie.stars[input][1])
		display_star(star)
	end

	def display_star(star)
		puts "\n#{star.name.upcase}\n#{star.subtext}"
		puts "#{"Born:".magenta} #{star.born.first(2).join(", ")} In #{star.born.last}"
		puts "\n#{"Biography:".magenta}"
		puts star.bio.gsub(/\.(?=(?:[^.]*\.[^.]*\.[^.]*\.[^.]*\.[^.]*\.)*[^.]*$)/,".\n\n     ")
		puts "\n#{"Known For:".magenta} #{star.known_for.join(", ")}"
	end

end