class Game
    attr_accessor :actor_w_director, :stars, :bios, :score, :turn_count,:question_count

    def initialize(movie)
        @actor_w_director = (movie.stars << movie.director).uniq
        @stars = actor_w_director.map{|a| Scraper.start_scraping_stars(a.last)}
        @bios = stars.map{|star| star.bio.gsub(/#{star.first_name}|#{star.last_name[0...-1]}\w+/,"")}
        @score = 0
        @turn_count = 0
        @question_count = 0
        @old_questions = []
    end

    def display_question
        question = pick_question
        @old_questions << question
        @question_count += 1
        question
	end

    def pick_question
        @random_bio = bios.sample
        @bio_paragraph = @random_bio.split(/\n\n/).grep(/\w/).sample
        @old_questions.include?(@bio_paragraph) ? pick_question : @bio_paragraph
    end

    def check_answer(index)
        @turn_count += 1
        if bios[index] == @random_bio
            add_score
            "CORRECT".green
        else 
            "#{"Sorry, The Correct Answer Is:".red} #{answer.fullname}\n"
        end
    end

    def answer
        index = bios.index(@random_bio)
        stars[index]
    end

    def choices
        stars.map.with_index(1){|star,i| "#{i}. #{star.fullname}"}.join(" | ")
    end
    
    def add_score
        @score += 1
    end

    def won?
        over? && score.eql?(turn_count)
    end
    
    def over?
        turn_count.eql? 5
    end

end