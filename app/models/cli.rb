class CLI
	PAGER = TTY::Pager.new
	FONT_A = Artii::Base.new :font => 'cricket'
	FONT_B = Artii::Base.new :font => 'cursive'
	NOT_FOUND = "
	!! Sorry... Movie Not Found in IMDB Top 250 List !!
			Please Try Again.  ☹
	==================================================
	"
	attr_accessor :winsize, :menu_a_array , :menu_b_array, :imbd_site,:menu_a_options,:menu_b_options,:movie_picked,:game_options,:game_menu_array,
				  :error_message,:options,:menu_arr,:line_size,:heading,:error_message

	def initialize
		@winsize = IO.console.winsize
		@menu_a_array = %w(Movies_List Search Quit)
		@menu_b_array =  %w(Play_Game Play_Trailer Play_Movie Actors Director)
		@game_menu_array =  %w(Play_Again Back_To_Movie Quit)
		@imbd_site = "https://www.imdb.com"
	end

	def run
		Scraper.new(imbd_site)
		activate_menu_options
		menu_a
	end

	# MENUS 
	def menu_a
		puts "#{File.open("imdb.txt").read}\n\n\n".center(winsize.last)
		@options,@menu_arr,@line_size = menu_a_options,menu_a_array,38
		@heading = "Select A Menu Option From 1-3"
		@error_message = "Please select from The Avialable options 1-3"
		create_print_menu
		switch
	end

	def menu_b
		@options,@menu_arr,@line_size = menu_b_options,menu_b_array,75
		@heading = "What Would You Like To Do:  select (1 - 3)"
		@error_message = "Please choose any options between 1-3 "
		create_print_menu
		switch
	end

	def game_menu
		@options,@menu_arr,@line_size = game_options,game_menu_array,58
		@heading = "Choose an Option Below: select (1-3)"
		@error_message = "Please choose any of theses options 1-3 "
		create_print_menu
		switch
	end

	def switch
		input = gets.chomp
		if options[input]
			options[input].()
		else
			@heading = error_message
			create_print_menu
			switch
		end
	end

	# THESE METHODS DISPLAY And SEARCH All MOVIES
	def display_all_movies
		movies = Movie.all
		table = create_movie_table(movies,"IMBD TOP 250")
		PAGER.page(table)
		@movie_picked = Scraper.movie_details(selected_movie(movies))
		display_selected_movie
	end

	def search
		print "Search By Movie Title: "
		input = gets.chomp
		movies = Movie.find_by_title(input)
		table = create_movie_table(movies,"From: IMBD TOP 250 MOVIES")
		puts table
		@movie_picked = Scraper.movie_details(selected_movie(movies))
		display_selected_movie
	end


	# WHEN A MOVIE IS CHOOSEN THE METHODS BELOW WILL CONTROL THE USERS EXPERIENCES  

	#Finds selected movie in movie array
	def selected_movie(movie_arr)
		input = make_index
		input.between?(0,movie_arr.size) ? movie_arr[input] : menu_a
	end

	#Shows info about selected movie
	def display_selected_movie
		puts "#{FONT_B.asciify(movie_picked.title)}\n\n#{movie_picked.title.upcase}\n#{movie_picked.subtext}"
		puts "\n#{"Summary:".magenta} #{movie_picked.summary}\n#{"Top 3 Actors:".magenta} #{movie_picked.stars.map{|e|e[0]}.join(", ")}"
		puts "#{"Directors:".magenta} #{movie_picked.director.first}"
		menu_b
	end
	
	def play_trailer
		Launchy.open(movie_picked.trailer) if movie_picked.trailer
		puts movie_picked.trailer ? FONT_A.asciify("Playing Trailer") : FONT_A.asciify("Sorry Trailer Not Available")
		continue(game_options,'2')
	end

	def play_movie
		movie_url = movie_picked.play_movie
		Launchy.open(movie_url) if movie_url
		puts movie_url ? FONT_A.asciify("Playing Movie") : FONT_A.asciify("Sorry Movie Not Available!!")
		continue(game_options,'2')
	end

	def make_index
		input = gets.chomp.to_i
		new_input = input.abs - 1
		input.nonzero? ? new_input : menu_a
	end

	#list all stars of selected movie
	def list_stars
		actors = movie_picked.stars.reject {|star| star.first.eql? movie_picked.director}
		@line_size = ((winsize.last - 80) / 2)
		rows = actors.map.with_index(1) {|actor,i| [i.to_s,actor.first]}
		table = Terminal::Table.new :title => "More Info About Your Actor: select Available options (1-3) ".cyan,:headings => ["Num".cyan,"Top Actors".cyan], :rows => rows
		table.style = { :padding_left => 3, :border_x => "=", :border_i => "*", :margin_left => line(" ")}
		puts table
		
		selected_star
	end
	
	# Shows choosen star information
	def selected_star
		input = make_index
		star_url = movie_picked.stars[make_index][1] if input.between?(0,movie_picked.stars.size - 1)
		list_stars if !input.between?(0,movie_picked.stars.size - 1)
		star = Scraper.start_scraping_stars(star_url)
		puts star.display_info
		continue(game_options,'2')
	end

	# Shows directors information
	def display_director
		director = Scraper.start_scraping_stars(movie_picked.director.last)
		puts director.display_info
		continue(game_options,'2')
	end

	def play_game
		game = Game.new(movie_picked)
		until game.over?
			puts File.open("question_mark.txt").read
			print "#{"\n\nQuestion #{game.question_count + 1}:".magenta}"
			puts  "Score: #{game.score}/5".center(winsize.last / 1.3).cyan
			puts game.display_question
			puts "\n\n#{"WHO AM I".center(winsize.last / 1.15).cyan}"
			puts "Choose A Answer Below or select #{"'q'".red} to #{"quit".red}".center(winsize.last / 1.01)
			line = line("-")
			print_center([line,game.choices,line])
			input = gets.chomp
			break if input == "q"
			puts game.check_answer(input.to_i - 1)
		end
		puts game.won? ? "Congratulations YOU WIN !!!".center(winsize.last / 1.4).green : "Gettem next time Tiger".center(winsize.last / 1.2)
		puts "#{"Your total score is: #{game.score}/5".center(winsize.last / 1.2).green}\n\n"
		game_menu
	end

	def continue(destination,key)
		puts "Press Enter to Continue"
		input = gets.chomp
		input.eql?("") ? destination[key].() : continue(destination,key)	
	end
	
	# CREATES LOGIC FOR MENU SWITCHES
	def activate_menu_options
		@menu_a_options = { '1' => method(:display_all_movies), '2' => method(:search), '3' => -> { puts 'quit' } }
		@menu_b_options = {	
							'm' => method(:menu_a), '1' => method(:play_game), '2' => method(:play_trailer),
							'3' => method(:play_movie),'4' => method(:list_stars),'5' => method(:display_director),
							'q' => -> { puts 'quit' }
						  }
		@game_options = {'1' => method(:play_game),'2' => method(:display_selected_movie),'3' => -> { puts 'quit' }}
	end

	# CREATES A TABLE FULL OF MOVIE TITLES 
	def create_movie_table(movies,title='')
		rows = create_rows(movies)
		table = Terminal::Table.new :title => title,:headings => ["Num","Movies"], :rows => rows
		table.style = { :padding_left => 3, :border_x => "-", :border_i => "x"}
		table.align_column(1, :center)
		table
	end
	
	# BUILDS ROWS FOR TABLE METHOD
	def create_rows(movies)
		rows = []
		movies.each.with_index(1) do |movie,i| 
			rows << ["#{i}.", "#{movie.title}"]
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

	# CREATE A LINE SEPERATOR
	def line(separator)
		a = [] 
		@line_size.times{a << separator}
		a.join('')
	end

end