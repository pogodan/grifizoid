Gem::Specification.new do |s|
  s.name = "grifizoid"
  s.version = "0.0.4"
  s.authors = "Paul Meserve"
  s.email = "dev@pogodan.com"
  s.homepage = "http://github.com/pogodan/grifizoid"
  s.platform = Gem::Platform::RUBY
  s.summary = "Rack middleware for Mongo GridFileSystem"
  s.description = "Rack middleware for Mongo GridFileSystem"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir["{lib,test}/**/*.rb"] + s.extra_rdoc_files
  
  s.add_dependency('mongo')
  s.rubyforge_project = "none"
end
