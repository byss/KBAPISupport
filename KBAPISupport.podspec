Pod::Spec.new do |spec|
	spec.name                 = 'KBAPISupport'
	spec.version              = '2.2.3'
	spec.license              = { :type => 'MIT' }
	spec.homepage             = 'https://github.com/byss/' + spec.name
	spec.authors              = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary              = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source               = { :git => spec.homepage + '.git', :tag => 'v' + spec.version.to_s }
	spec.requires_arc         = true
	spec.source_files         = 'KBAPISupport/*.{h,m}'
	spec.private_header_files = 'KBAPISupport/ARCSupport.h'
	spec.exclude_files        = 'KBAPISupport/KBAPISupport-pods-config.h'
	spec.platform             = :ios # temporary solution for error when `watchos` platform cannot be found
	spec.prepare_command = <<-EOF
		pushd KBAPISupport &&
		cp KBAPISupport-pods-config.h KBAPISupport-config.h &&
		./KBAPISupport-prepare.sh &&
		popd &&
		touch KBAPISupport-fake-spec.m
	EOF
	
	spec.subspec 'Debug' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_DEBUG -DKBAPISUPPORT_DEBUG=1'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'JSON' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_JSON -DKBAPISUPPORT_JSON=1'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'NOJSON' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_JSON -DKBAPISUPPORT_JSON=0'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'XML' do |sspec|
		sspec.dependency 'GDataXML-HTML', '~> 1.2.0'
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_XML -UKBAPISUPPORT_PODS_BUILD -DKBAPISUPPORT_XML=1 -DKBAPISUPPORT_PODS_BUILD=1',
			'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'Decode_CP1251' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_DECODE -UKBAPISUPPORT_DECODE_FROM -DKBAPISUPPORT_DECODE=1 -DKBAPISUPPORT_DECODE_FROM=(NSWindowsCP1251StringEncoding)'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'Delegates' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_USE_DELEGATES -DKBAPISUPPORT_USE_DELEGATES=1'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'NODelegates' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_USE_DELEGATES -DKBAPISUPPORT_USE_DELEGATES=0'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'Blocks' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_USE_BLOCKS -DKBAPISUPPORT_USE_BLOCKS=1'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	spec.subspec 'ExtensionSafe' do |sspec|
		sspec.xcconfig = {
			'OTHER_CFLAGS' => '-UKBAPISUPPORT_EXTENSION_SAFE -DKBAPISUPPORT_EXTENSION_SAFE=1'
		}
		sspec.preserve_paths = 'KBAPISupport/KBAPISupport-config.h'
	end
	
# 	spec.subspec 'JSON+Delegates' do |sspec|
# 		sspec.dependency 'KBAPISupport/JSON'
# 		sspec.dependency 'KBAPISupport/Delegates'
# 	end
# 	spec.subspec 'JSON+Blocks' do |sspec|
# 		sspec.dependency 'KBAPISupport/JSON'
# 		sspec.dependency 'KBAPISupport/Blocks'
# 	end
# 	spec.subspec 'XML+Delegates' do |sspec|
# 		sspec.dependency 'KBAPISupport/XML'
# 		sspec.dependency 'KBAPISupport/Delegates'
# 	end

	spec.default_subspecs = 'JSON', 'Delegates'
end
