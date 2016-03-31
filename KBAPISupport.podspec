Pod::Spec.new do |spec|
	spec.name                 = 'KBAPISupport'
	spec.version              = '3.0.0-a00'
	spec.license              = { :type => 'MIT' }
	spec.homepage             = 'https://github.com/byss/' + spec.name
	spec.authors              = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary              = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source               = { :git => spec.homepage + '.git', :tag => 'v' + spec.version.to_s }
	spec.requires_arc         = true
	
	spec.subspec 'Core' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	spec.subspec 'NSURLConnection' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	spec.subspec 'NSURLSession' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	spec.subspec 'JSON' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
# 	TODO
# 	spec.subspec 'XML' do |sspec|
# 		sspec.dependency 'GDataXML-HTML', '~> 1.2.0'
# 		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
# 		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
# 	end
	spec.subspec 'Mapping' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	spec.subspec 'Delegates' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	spec.subspec 'Blocks' do |sspec|
		sspec.source_files = 'KBAPISupport/' + sspec.name + '/*.{h,m}'
		sspec.private_header_files = 'KBAPISupport/' + sspec.name + '/*_Protected.h'
	end
	
	spec.default_subspecs = 'Core', 'NSURLConnection', 'JSON', 'Mapping', 'Blocks'
end
