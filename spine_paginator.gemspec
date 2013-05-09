# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spine_paginator/version'

Gem::Specification.new do |gem|
  gem.name          = "spine_paginator"
  gem.version       = SpinePaginator::VERSION
  gem.authors       = ["vkill"]
  gem.email         = ["vkill.net@gmail.com"]
  gem.description   = %q{Paginator for Spine}
  gem.summary       = %q{Paginator for Spine}
  gem.homepage      = "https://github.com/vkill/spine_paginator"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
