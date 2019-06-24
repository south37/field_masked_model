
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "field_masked_model/version"

Gem::Specification.new do |spec|
  spec.name          = "field_masked_model"
  spec.version       = FieldMaskedModel::VERSION
  spec.authors       = ["Nao Minami"]
  spec.email         = ["south37777@gmail.com"]

  spec.summary       = %q{FieldMaskedModel provides masked accessor methods to models}
  spec.description   = %q{FieldMaskedModel provides masked accessor methods to models}
  spec.homepage      = "https://github.com/south37/field_masked_model"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_runtime_dependency "fmparser", "0.1.0"
  spec.add_runtime_dependency "google-protobuf", "~> 3.7"
end
