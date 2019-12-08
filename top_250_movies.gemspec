Gem::Specification.new do |s|
    s.name = %q{top_250_movies}
    s.version = "0.0.0"
    s.date = %q{2011-09-29}
    s.summary = %q{top_250_movies scrapes 250 movies from IMDB website}
    s.authors = ["Nethelbert Blasse"]
    s.email = ["nethelbert.blasse@gmail.com"]
    s.homepage = "https://github.com/Gilblasse/CLI-Project.git"
    s.license = "MIT"
    s.files = `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
    s.bindir = "exe"
    s.executables = s.files.grep(%r(^exe/)) { |f| File.basename(f) }
    s.require_paths = ["models"]

    s.add_development_dependency "bundler", "~> 2.0", ">= 2.0.2"
    s.add_development_dependency "rspec", "~> 3.9"
  end