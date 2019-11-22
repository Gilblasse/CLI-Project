require_relative './config/environment.rb'

def reload
  load 'config/environment.rb'
end

#examples:
CLI.new.run


# binding.pry