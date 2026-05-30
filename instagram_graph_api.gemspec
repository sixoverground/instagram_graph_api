# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'instagram_graph_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'instagram_graph_api'
  spec.version       = InstagramGraphAPI::VERSION
  spec.authors       = ['Craig Phares']
  spec.email         = ['craig@sixoverground.com']

  spec.summary       = 'Instagram Graph API client'
  spec.description   = 'A Ruby wrapper for the Instagram Graph API, supporting Business and Creator accounts.'
  spec.homepage      = 'https://github.com/sixoverground/instagram_graph_api'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md'].reject { |f| File.directory?(f) }
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday',       '>= 2.0', '< 3.0'
  spec.add_runtime_dependency 'hashie',        '>= 5.0', '< 6.0'

  spec.add_development_dependency 'rake',     '~> 13.0'
  spec.add_development_dependency 'rspec',    '~> 3.12'
  spec.add_development_dependency 'webmock',  '~> 3.18'
end
