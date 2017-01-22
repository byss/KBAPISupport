class Pod::Specification
	def kb_subspec (name, priv_hdr = false, &block)
		self.subspec name do |sspec|
			sspec.source_files = "#{self.name}/#{name}/*.{h,m}"
			
			if priv_hdr
				sspec.private_header_files = "#{self.name}/#{name}/*_Protected.h"
			end
			if name != 'Core'
				sspec.dependency "#{self.name}/Core"
			end
			
			yield sspec if block_given?
		end
	end
end

Pod::Spec.new do |spec|
	spec.name         = 'KBAPISupport'
	spec.version      = '3.0.0-b07'
	spec.license      = { :type => 'MIT' }
	spec.homepage     = "https://github.com/byss/#{spec.name}"
	spec.authors      = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary      = 'Simple library for HTTP/HTTPS requests and parsing & mapping JSON/XML responses to native objects.'
	spec.source       = { :git => "#{spec.homepage}.git", :tag => "v#{spec.version}" }
	spec.requires_arc = true
	spec.source_files = "#{spec.name}/Supporting Files/#{spec.name}.h"
	spec.module_map   = "#{spec.name}/Supporting Files/#{spec.name}.modulemap"
	
	spec.ios.deployment_target = '7.0'
	spec.osx.deployment_target = '10.9'
	spec.watchos.deployment_target = '2.0'
	spec.tvos.deployment_target = '9.0'
	
	spec.kb_subspec 'Core', true do |sspec|
		sspec.frameworks = 'Foundation'
	end
	
	spec.kb_subspec 'NSURLConnection', true do |sspec|
		sspec.ios.deployment_target = '7.0'
		sspec.osx.deployment_target = '10.9'
	end
	spec.kb_subspec 'NSURLSession', true
	
	spec.kb_subspec 'JSON'
# 	TODO
# 	spec.kb_subspec 'XML' do |sspec|
# 		sspec.dependency 'GDataXML-HTML', '~> 1.2.0'
# 	end

	spec.kb_subspec 'CoreMapping'
	spec.kb_subspec 'ObjectMapping' do |sspec|
		sspec.dependency "#{spec.name}/CoreMapping"
	end

	spec.kb_subspec 'Blocks'
# 	TODO
#	spec.kb_subspec 'Delegates'

	spec.kb_subspec 'NetworkIndicator' do |sspec|
		sspec.ios.frameworks = 'UIKit'
		sspec.ios.deployment_target = '7.0'
	end
	
	spec.subspec 'KBLogger-dependency' do |sspec|
		sspec.dependency 'KBLogger', '~> 1.0'
	end
	
	spec.default_subspecs = 'NSURLSession', 'JSON', 'ObjectMapping', 'Blocks'
end
