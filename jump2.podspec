Pod::Spec.new do |jump|
  jump.name             = "jump2"
  jump.version          = "2.0.0"
  jump.license          = 'Apache Version 2'
  jump.homepage         = "https://github.com/seqoy/jump2"
  jump.author           = { "Paulo Oliveira" => "eu@pauloliveira.net" }
  jump.social_media_url = 'https://twitter.com/jumpLib'

  jump.summary          = "JUMP Framework is a collection of classes in Objective-C to perform a series of tasks on iOS or Mac OS applicationjump. "
  jump.description      = "JUMP Framework is a collection of classes in Objective-C to perform a series of tasks on iOS or Mac OS applications." \
  						  "From Network libraries until User Interface libraries. The framework have classes to accomplish day by day tasks" \
  						  "until very complex applications."
  
  jump.source           = { :git => "https://github.com/seqoy/jump2.git", :tag => '2.0' }

  jump.platform     = :ios, '7.0'
  jump.ios.deployment_target = '6.0'
  jump.requires_arc = true

  jump.default_subspec = 'Core'
  
   jump.subspec 'Core' do |c|
	    c.source_files = 'src/core/src/*.{h,m}'
   end

   jump.subspec 'Logging' do |log|
	    log.source_files = 'src/database/src/*.{h,m}'
	    log.ios.frameworks = 'CFNetwork', 'SystemConfiguration'

        log.dependency 'jump2/Core'

        log.dependency 'NSLogger'
        log.dependency 'Log4Cocoa'
   end

   jump.subspec 'Database' do |db|
	    db.source_files = 'src/database/src/*.{h,m}'
	    db.ios.frameworks = 'CoreData'
        
        db.dependency 'jump2/Core'
        db.dependency 'jump2/Logging'

   end


end
