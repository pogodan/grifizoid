# Grifizoid
  
  This is intended to be a simple Rack middleware for hosting site assets in a MongoDB [GridFileSystem](http://www.mongodb.org/display/DOCS/GridFS+in+Ruby). Right now it assumes you're using [Mongoid](http://mongoid.org/), mostly as a simple way to avoid needing any custom connection-management code

Unlike most similar tools, this is doing the lookup on the raw file path itself (optionally customized by passing a block to the initializer), not using a BSON ObjectID. The intended use-case for is storing site assets in GridFS directly and accessing them with normal human-friendly URLs, just like if they were sitting on your hard drive

It's sending a file handler not the raw data, so this should be low-memory use even for large files. It will set `Etag` and `Last-Modified` headers, and respond with a `304 Not Modified` when possible. Any additional caching you should do yourself where appropriate

## Installation

    # Gemfile
    gem 'grifizoid', :git => 'git://github.com/pogodan/grifizoid.git'

## Use with Rails 3

    # application.rb
    config.middleware.use Rack::GridFS do |req|
      site      = Site.where(:host => req.host).first
    
      File.join(site.to_param, req.path_info)
    end
  
Now someone going to http://mydomain.com/file.jpg will result in the middleware doing a query to find the site 'mydomain.com' (with an ID like `4d80c69f4cfad13cd100000c`) and then looks for a GridFS file named `4d80c69f4cfad13cd100000c/file.jpg`, sending it through to the client if found or else passing the request through to your app

Some ideas/code taken from:
  https://github.com/dusty/rack_grid
  https://github.com/skinandbones/rack-gridfs