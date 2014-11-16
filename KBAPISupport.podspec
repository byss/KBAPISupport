class Pod::Spec
	def setup_config_bit(config_bit)
		self.source_files = 'KBAPISupport/ConfigBits/_KB_#{config_bit}.h'
	end
end

Pod::Spec.new do |spec|
	spec.name                 = 'KBAPISupport'
	spec.version              = '2.0.1'
	spec.license              = { :type => 'MIT' }
	spec.homepage             = 'https://github.com/byss/' + spec.name
	spec.authors              = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary              = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source               = { :git => spec.homepage + '.git', :tag => 'v' + spec.version.to_s }
	spec.requires_arc         = true
	spec.preserve_paths       = 'KBAPISupport/KBAPISupport-config.h'
	
	spec.subspec 'Debug' do |sspec_debug|
		sspec_debug.setup_config_bit('DEBUG')
	end
	spec.subspec 'JSON' do |sspec_json|
		sspec_json.setup_config_bit('JSON')
	end
	spec.subspec 'XML' do |sspec_xml|
		sspec_xml.setup_config_bit('XML')
		sspec_xml.dependency 'GDataXML-HTML', '~> 1.2.0'
		sspec_xml.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
	end
	spec.subspec 'Decode_CP1251' do |sspec_decode_1251|
		sspec_decode_1251.setup_config_bit('CP1251')
	end
	spec.subspec 'Delegates' do |sspec_delegates|
		sspec_delegates.setup_config_bit('DELEGATES')
	end
	spec.subspec 'Blocks' do |sspec_blocks|
		sspec_blocks.setup_config_bit('BLOCKS')
	end
	
	spec.subspec 'Library' do |sspec_lib|
		sspec_lib.source_files         = 'KBAPISupport/*.{h,m}'
		sspec_lib.private_header_files = 'KBAPISupport/ARCSupport.h'
		sspec_lib.prepare_command = <<-EOF
			shopt -s extglob;
			pushd KBAPISupport &&
			cat ConfigBits/!(_KB_FOOTER.h) ConfigBits/_KB_FOOTER.h > 'KBAPISupport-config.h'
			cp 'KBAPISupport-config.h' ~/tmp/CONFEEG.h &&
			./KBAPISupport-prepare.sh &&
			popd
		EOF
	end
	
# 	spec.subspec 'JSON+Delegates' do |sspec_json_delegates|
# 		sspec_json_delegates.dependency 'KBAPISupport/JSON'
# 		sspec_json_delegates.dependency 'KBAPISupport/Delegates'
# 	end
# 	spec.subspec 'JSON+Blocks' do |sspec_json_blocks|
# 		sspec_json_blocks.dependency 'KBAPISupport/JSON'
# 		sspec_json_blocks.dependency 'KBAPISupport/Blocks'
# 	end
# 	spec.subspec 'XML+Delegates' do |sspec_xml_delegates|
# 		sspec_xml_delegates.dependency 'KBAPISupport/XML'
# 		sspec_xml_delegates.dependency 'KBAPISupport/Delegates'
# 	end
	spec.default_subspecs = 'JSON', 'XML', 'Delegates', 'Blocks', 'Library'
end
