require_relative "lib/bullet_train/http_filter/version"

Gem::Specification.new do |spec|
  spec.name = "bullet_train-http_filter"
  spec.version = BulletTrain::HTTPFilter::VERSION
  spec.authors = ["Andrew Culver"]
  spec.email = ["andrew.culver@gmail.com"]
  spec.homepage = "https://github.com/bullet-train-co/bullet_train-http_filter"
  spec.summary = "Bullet Train HTTP Filter"
  spec.description = spec.summary

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "test/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency 'addressable', '~> 2.5'

  spec.license = "MIT"
end
