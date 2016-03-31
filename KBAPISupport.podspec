Pod::Spec.new do |spec|
	spec.name                 = 'KBAPISupport'
	spec.version              = '3.0.0-a00'
	spec.license              = { :type => 'MIT' }
	spec.homepage             = 'https://github.com/byss/' + spec.name
	spec.authors              = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary              = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source               = { :git => spec.homepage + '.git', :tag => 'v' + spec.version.to_s }
	spec.requires_arc         = true
	
	spec.ios.deployment_target = '6.0'
	spec.osx.deployment_target = '10.8'
	
	spec.subspec 'Core' do |sspec|
		sspec.source_files = 'KBAPISupport/Core/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/Core/*_Protected.h'
	end
	spec.subspec 'NSURLConnection' do |sspec|
		sspec.source_files = 'KBAPISupport/NSURLConnection/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
	end
	spec.subspec 'NSURLSession' do |sspec|
		sspec.source_files = 'KBAPISupport/NSURLSession/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
		spec.ios.deployment_target = '7.0'
		spec.osx.deployment_target = '10.9'
	end
	spec.subspec 'JSON' do |sspec|
		sspec.source_files = 'KBAPISupport/JSON/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
	end
# 	TODO
# 	spec.subspec 'XML' do |sspec|
# 		sspec.dependency 'GDataXML-HTML', '~> 1.2.0'
# 		sspec.source_files = 'KBAPISupport/XML/*.{h,m}'
# 		sspec.dependency 'KBAPISupport/Core'
# 	end
	spec.subspec 'Mapping' do |sspec|
		sspec.source_files = 'KBAPISupport/Mapping/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
	end
	spec.subspec 'Blocks' do |sspec|
		sspec.source_files = 'KBAPISupport/Blocks/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
	end
	spec.subspec 'Delegates' do |sspec|
		sspec.source_files = 'KBAPISupport/Delegates/*.{h,m}'
		sspec.dependency 'KBAPISupport/Core'
	end
	
	spec.default_subspecs = 'Core', 'NSURLConnection', 'JSON', 'Mapping', 'Blocks'
end
