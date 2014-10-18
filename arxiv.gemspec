s = Gem::Specification.new do |s|
  s.name        = 'paper_arxiv'
  s.version     = '0.0.1'
  s.summary     = 'Simple wrapper for the Arxiv API'
  s.description = 'Simple wrapper for Arxiv API exposing common fields.'
  s.authors     = ['']
  s.email       = 'mattr@fastmail.fm'
  s.files       = ['lib/paper_arxiv.rb']
  s.homepage    = ''
end

s.add_dependency('nokogiri')
s
