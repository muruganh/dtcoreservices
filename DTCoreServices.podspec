Pod::Spec.new do |s|
s.name             = 'DTCoreServices'
s.version          = '1.0.1' 
s.summary          = 'Custom pod creation for iOS' 
s.description      = <<-DESC "To use api request and response call"
DTCore library!
DESC

s.homepage         = 'https://github.com/muruganh/dtcoreservices'
s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
s.author           = { 'username' => 'muruganhios@gmail.com' }
s.source           = { :git => 'https://github.com/muruganh/dtcoreservices.git', :tag => s.version.to_s }
s.ios.deployment_target = '11.0'
s.source_files = 'Sources/*'
end