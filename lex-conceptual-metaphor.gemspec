# frozen_string_literal: true

require_relative 'lib/legion/extensions/conceptual_metaphor/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-conceptual-metaphor'
  spec.version       = Legion::Extensions::ConceptualMetaphor::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Conceptual Metaphor'
  spec.description   = 'Lakoff & Johnson conceptual metaphor theory — understanding abstractions ' \
                       'through embodied metaphors for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-conceptual-metaphor'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-conceptual-metaphor'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-conceptual-metaphor'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-conceptual-metaphor'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-conceptual-metaphor/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-conceptual-metaphor.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
