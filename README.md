# Rack::Sprocketize

Rack::Sprocketize is a piece of Rack Middleware which uses [Sprockets](http://getsprockets.org/) to concatenate javascript files and then optionally compresses them. In a development environment, the files will be sprocketized on each request if there have been changes to the source files. In a production environment, the files will only be sprocketized one time, and only if there have been changes. Also, in a production environment, the files will be compressed by whichever javascript compressor is available.

## Installation
    
    gem install rack-sprocketize
    
## Basic Usage

In a Rack based app, use Rack::Sprocketize just like any other middleware, passing options if necessary.

    require 'rack-sprocketize'
    use Rack::Sprocketize, :always_compress => true
    
In a Rails 3 app, Rack::Sprocketize is automatically included in the middleware stack, so all you need to worry about  is configuration.
    
    # Gemfile
    gem 'rack-sprocketize'
    
    # config/application.rb
    config.sprocketize.always_compress = true
    
### Sprocketizing
    
Rack::Sprocketize takes each file in the given `:source_path` (`'app/javascripts'` by default) and uses Sprockets to include any other required files. Then it outputs the results in the `:output_path` (`'public/javascripts` by default). Also, files that begin with `'_'` will not be sprocketized and will essentially be treated like partials.

So, given the following files in an app:

    # app/javascripts/main.js
    //= require "_partial"
    
    # app/javascripts/_partial.js
    var hello = 'world';
    
    # app/javascripts/plugin.js
    var plugin = 'blah';
    
Rack::Sprocketize will sprocketize them into `:output_path` like this:

    # public/javascripts/main.js
    var hello = 'world';
    
    # public/javascripts/plugin.js
    var plugin = 'blah';
    
Notice how the files weren't all concatenated into one file. You use Sprockets' `//= require` syntax to control how the files will be concatenated.

Both the `:source_path` and `:output_path` can be customized when setting up Rack::Sprocketize:

    use Rack::Sprocketize, :source_path => 'js', :output_path => 'public/js'
      
### Compression
      
Rack::Sprocketize determines which javascript compressor you want to use based on which one has been required. 

    require 'packr'
    use Rack::Sprocketize
    # would use Packr
    
or in Rails:

    # Gemfile
    gem 'jsmin'
    
    # config/application.rb
    config.middleware.use Rack::Sprocketize
    # would use JSMin

To pass options to the javascript compressor just use the `:compression_options` option:

    require 'packr'
    use Rack::Sprocketize, :compression_options => { :shrink_vars => true }
    
By default, the files are only compressed in a production environment. If for some reason you want them to always be compressed, pass the `:always_compress` option:

    use Rack::Sprocketize, :always_compress => true
    
Any files suffixed with `'.min'` or `'-min'` will not be compressed. For example, `'app/javascripts/jquery.min.js'` would not be re-compressed when it is sprocketized.

## Copyright

Copyright (c) 2011 [Peter Browne](http://petebrowne.com). See LICENSE for details.
