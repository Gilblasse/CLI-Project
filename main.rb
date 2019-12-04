require_relative './config/environment.rb'

def reload
  load 'config/environment.rb'
end

#examples:

cli = CLI.new
cli.run


# binding.pry