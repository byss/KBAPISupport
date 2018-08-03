class Pod::Specification
	def kb_subspec (name, requires: nil, &block)
		self.subspec name do |sspec|
			sspec.source_files = "#{sspec.name}/*.{h,mm,swift}", "#{sspec.name}/Private/*.{h,mm,swift}", "#{self.name}/Supporting Files/#{self.name}.h", "#{self.name}/Supporting Files/#{self.name}-Private.h"
			sspec.private_header_files = "#{sspec.name}/Private/*.h"
			sspec.dependency "#{self.name}/#{requires}" if requires
			yield sspec if block_given?
		end
	end
end

Pod::Spec.new do |spec|
	spec.name         = 'KBAPISupport'
	spec.version      = '4.0.0-a00'
	spec.license      = { :type => 'MIT' }
	spec.homepage     = "https://github.com/byss/#{spec.name}"
	spec.authors      = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary      = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source       = { :git => "#{spec.homepage}.git", :tag => "v#{spec.version}" }
	spec.requires_arc = false
	
	spec.ios.deployment_target = '10.0'
	spec.osx.deployment_target = '10.11'
	spec.watchos.deployment_target = '4.0'
	spec.tvos.deployment_target = '10.0'

	spec.module_map   = "#{spec.name}/Supporting Files/#{spec.name}.modulemap"

	spec.kb_subspec 'Utils'
	spec.kb_subspec 'Core', :requires => 'Utils'
	spec.kb_subspec 'ObjC', :requires => 'Core'
	spec.kb_subspec 'UIKit', :requires => 'Core'

	spec.default_subspecs = 'Core'
end
