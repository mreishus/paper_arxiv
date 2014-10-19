# -*- encoding: utf-8 -*-
# stub: paper_arxiv 0.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "paper_arxiv"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = [""]
  s.date = "2014-10-19"
  s.description = "Simple wrapper for Arxiv API exposing common fields."
  s.email = "mattr@fastmail.fm"
  s.files = ["lib/paper_arxiv.rb"]
  s.homepage = ""
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.2.2"
  s.summary = "Simple wrapper for the Arxiv API"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
