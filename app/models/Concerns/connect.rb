module Connect
    def roles
		Role.all.select{|role| role.movie == self }
	end
end