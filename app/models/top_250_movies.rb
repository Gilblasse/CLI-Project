require_relative "./top_250_movies/version.rb"
module Top250Movies

	class CLI
		attr_accessor :winsize, :main_menu_array , :selected_movie_array, :imbd_site,:main_menu_options,:selected_movie_options,
					:movie_picked,:game_options,:game_menu_array,:error_message,:options,:menu_arr,:line_size,:heading,:error_message
		# PAGER = TTY::Pager.new

		def initialize
			@winsize = IO.console.winsize
			@main_menu_array = %w(Movies_List Search Quit)
			@selected_movie_array =  %w(Play_Game Play_Trailer Play_Movie Actors Director)
			@game_menu_array =  %w(Play_Again Back_To_Movie Quit)
			@sort = ""
			activate_menu_options
		end

		def run
			@scraper = Scraper.new
			@scraper.first_page
			main_menu
		end

		# MENUS 
		def main_menu
			puts "#{File.open("pics/imdb.txt").read}\n\n\n".center(winsize.last)
			@options,@menu_arr,@line_size = main_menu_options,main_menu_array,38
			@heading = "Select A Menu Option From 1-3 " 
			@error_message = "Please select from The Avialable options between 1 - 3"
			create_print_menu
			menu_switch
		end

		def selected_movie_menu
			@options,@menu_arr,@line_size = selected_movie_options,selected_movie_array,75
			@heading = "Select options (1 - 5) or ('m') for Main Menu or ('q') to Quit"
			@error_message = "Please choose any options between 1-5 "
			create_print_menu
			menu_switch
		end

		def game_menu
			@options,@menu_arr,@line_size = game_options,game_menu_array,58
			@heading = "Choose an Option Below: select (1-3)"
			@error_message = "Please choose any of theses options 1-3 "
			create_print_menu
			menu_switch
		end

		def menu_switch
			input = gets.chomp
			if @options[input]
				@options[input].()
			else
				@heading = error_message
				create_print_menu
				menu_switch
			end
		end
		
		def sorting_menu
			print_center(["SORT BY: (1) A-Z | (2) Most_Recent | (3) Highest_Ratings | (4) Go_Back"])
			input = gets.chomp.to_i
			case input 
			when 1
				@sort = "sort_by_alphabetical_order"
			when 2
				@sort = "sort_by_year"
			when 3
				@sort = "sort_by_highest_ratings"
			when 4
				main_menu
			else
				print_center ["Please Choose From The Options Outlined"]
				sorting_menu
			end
		end


		# THESE METHODS DISPLAY And SEARCH All MOVIES
		def display_all_movies
			sorting_menu 
			@list_of_movies = Movie.send(@sort)
			@list_header = "IMBD TOP 250"
			list_movies
		end

		def search
			print "Search By Movie Title: "
			@list_of_movies = Movie.matching_titles
			@list_header = "IMBD TOP 250 MOVIES"
			@list_of_movies.class.eql?(Proc) ? (@list_of_movies.(); search) : list_movies
		end

		def list_movies 
			puts create_movie_table
			movie = selected_movie
			main_menu if movie.nil?
			@movie_picked = @scraper.second_page(movie)
			display_selected_movie
		end



		##############################################################################
		# WHEN A MOVIE IS CHOOSEN THE METHODS BELOW WILL CONTROL THE USERS EXPERIENCES  
		###############################################################################

		#Finds selected movie in movie array
		def selected_movie
			input = make_index
			main_menu if input.nil?
			@list_of_movies[input] if input.between?(0,@list_of_movies.size - 1)
		end

		#Shows info about selected movie
		def display_selected_movie
			puts movie_picked.display_movie_info
			selected_movie_menu
		end
		
		def play_trailer
			puts movie_picked.play_trailer_w_message
			continue(game_options,'2')
		end

		def play_movie
			puts movie_picked.play_movie_w_message
			continue(game_options,'2')
		end

		#list all stars of selected movie
		def list_stars
			@line_size = ((winsize.last - 95) / 2)
			rows = movie_picked.stars.map.with_index(1) {|star,i| [i.to_s,star.fullname] } 

			table = Terminal::Table.new :title => "More Info About Your Actor: select Available options (1-3) ".cyan,:headings => ["Num".cyan,"Top Actors".cyan], :rows => rows
			table.style = { :padding_left => 3, :border_x => "=", :border_i => "*", :margin_left => line(" ")}
			puts table
			
			selected_star
		end
		
		# Shows choosen star information
		def selected_star
			input = make_index
			star_url = movie_picked.stars[input].url if input.between?(0,movie_picked.stars.size - 1)
			list_stars if !input.between?(0,movie_picked.stars.size - 1)
			star = @scraper.find_or_scrape_person(star_url)
			puts star.display_info
			continue(game_options,'2')
		end

		# Shows directors information
		def display_director
			director = @scraper.find_or_scrape_person(movie_picked.director.first.url)
			puts director.display_info
			continue(game_options,'2')
		end

		def play_game
			game = Game.new(movie_picked)
			game.play
			puts game.over_message
			game_menu
		end

		def continue(destination,key)
			puts "Press Enter to Continue"
			input = gets.chomp
			input.eql?("") ? destination[key].() : continue(destination,key)	
		end
		
		# CREATES LOGIC FOR MENU SWITCHES
		def activate_menu_options
			@main_menu_options = { '1' => method(:display_all_movies), 
								'2' => method(:search), 
								'3' => -> { puts 'quit' }
							}
			@selected_movie_options = {	
								'm' => method(:main_menu), 
								'1' => method(:play_game), 
								'2' => method(:play_trailer),
								'3' => method(:play_movie),
								'4' => method(:list_stars),
								'5' => method(:display_director),
								'q' => -> { puts 'quit' }
							}
			@game_options = {'1' => method(:play_game),'2' => method(:display_selected_movie),'3' => -> { puts 'quit' }}
		end

		# CREATES A TABLE FULL OF MOVIE TITLES 
		def create_movie_table
			@line_size = ((winsize.last - 165) / 2)
			table = Terminal::Table.new :title => @list_header,:headings => ["NUM".center(31),"MOVIES".center(80),"YEAR","RATING"], :rows => create_rows
			table.style = { :padding_left => 3, :border_x => "-", :border_i => "x", :margin_left => line(" "),:width => 150}
			table.align_column(1, :center)
			table.align_column(0, :center)
			table
		end
		
		# BUILDS ROWS FOR TABLE METHOD
		def create_rows
			rows = []
			@list_of_movies.each.with_index(1) do |movie,i| 
				rows << ["#{i}.", "#{movie.title}","#{movie.year}","#{movie.rating}"]
				rows << :separator
			end
			rows
		end

		# DESIGNS A MENU WITH CUSTOM MENU INFORMATION
		def create_print_menu
			line = line("-")
			menu = menu_arr.map.with_index(1){|option,i| "#{i}. #{option}" }.join(" | ")
			print_center([heading,line,menu,line])
		end

		# PRINT ANYTHING TO THE CENTER OF THE TERMINAL
		def print_center(array)
			array.each{|e| printf("%#{((winsize.last + e.size)-28)/2}s\n", e) }
		end

		# CONVERTS INPUT TO INTEGER 
		def make_index
			input = gets.chomp.to_i
			new_input = input.abs - 1
			input.nonzero? ? new_input : main_menu
		end

		# CREATE A LINE SEPERATOR
		def line(separator)
			a = [] 
			@line_size.times{a << separator}
			a.join('')
		end
		

	end

end