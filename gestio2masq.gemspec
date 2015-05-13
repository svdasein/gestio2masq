# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "gestio2masq"
  spec.version       = '0.0.2'
  spec.authors       = ["svdasein"]
  spec.email         = ["daveparker01@gmail.com"]

  spec.summary       = %q{Binary generates DNSmasq conifguration files from Gestioip data}
  spec.description   = %q{This gem provides a binary that generates dnsmasq dns and dhcp configuration from a gestioip\
database.  Currently only mysql databases are supported}
  spec.homepage      = "http://github.com/svdasein/gestio2masq"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib","bin"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end