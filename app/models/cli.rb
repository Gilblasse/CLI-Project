class CLI
	BASE_PATH = "https://www.imdb.com/chart/top"

	def run
		puts
		puts "========================="
		puts "IMBD 250 TOP RATED MOVIES"
		puts "========================="
		puts
		Scraper.new(BASE_PATH)
		menu
	end

	def menu
		puts "1. Show List of Movies"
		puts "----------------------"
		menu_switch
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
		Scraper.movie_details(selected_movie)
	end

	def selected_movie
		input = make_index
		Movie.all[input] if input.between?(0,Movie.all.size)
	end

end