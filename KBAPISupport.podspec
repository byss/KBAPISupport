Pod::Spec.new do |spec|
	spec.name         = 'KBAPISupport'
	spec.version      = '4.0.0-a00'
	spec.license      = { :type => 'MIT' }
	spec.homepage     = "https://github.com/byss/#{spec.name}"
	spec.authors      = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary      = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source       = { :git => "#{spec.homepage}.git", :tag => "v#{spec.version}" }
	spec.requires_arc = false
	spec.module_map   = "#{spec.name}/Supporting Files/#{spec.name}.modulemap"
	
	spec.ios.deployment_target = '10.0'
	spec.osx.deployment_target = '10.11'
	spec.watchos.deployment_target = '4.0'
	spec.tvos.deployment_target = '10.0'
	
	spec.source_files = "#{spec.name}/**/*.{h,mm,swift}"
end
