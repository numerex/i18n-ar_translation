# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n-ar_translation/version'

Gem::Specification.new do |gem|
  gem.name          = 'i18n-ar_translation'
  gem.version       = I18n::ArTranslation::VERSION
  gem.authors       = %w(spemmons)
  gem.email         = %w(s.p.emmons@gmail.com)
  gem.description   = %q{Support a translation process using i18n-active_record}
  gem.summary       = %q{The translation process used in this gem draws from prior work in i18n_backend_database}
  gem.homepage      = 'https://github.com/spemmons/i18n-ar_translation'

  gem.files         = %x(git ls-files).split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |file| File.basename(file) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_dependency 'rails', '~> 3.2.12'
  gem.add_dependency 'i18n-active_record'

end
