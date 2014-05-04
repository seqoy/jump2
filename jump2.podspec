Pod::Spec.new do |jump|
  jump.name             = "jump2"
  jump.version          = "2.0.1"
  jump.license          = 'Apache Version 2'
  jump.homepage         = "https://github.com/seqoy/jump2"
  jump.author           = { "Paulo Oliveira" => "eu@pauloliveira.net" }
  jump.social_media_url = 'https://twitter.com/jumpLib'

  jump.summary          = "JUMP Framework is a collection of classes in Objective-C to perform a series of tasks on iOS or Mac OS applicationjump. "
  jump.description      = "JUMP Framework is a collection of classes in Objective-C to perform a series of tasks on iOS or Mac OS applications." \
  						  "From Network libraries until User Interface libraries. The framework have classes to accomplish day by day tasks" \
  						  "until very complex applications."
  
  jump.source           = { :git => "https://github.com/seqoy/jump2.git", :tag => '2.0.1' }

  jump.platform     = :ios, '7.0'
  jump.ios.deployment_target = '6.0'
  jump.requires_arc = true

  jump.default_subspec = 'Core'
  
   jump.subspec 'Core' do |c|
        c.dependency 'ObjectiveSugar'
	    c.source_files = 'src/core/*.{h,m}'
   end

   jump.subspec 'Database' do |db|
        db.dependency 'jump2/Core'
	    db.source_files = 'src/database/*.{h,m}'
   end

   jump.subspec 'Data' do |data|
        data.dependency 'jump2/Core'
	    data.source_files = 'src/data/*.{h,m}'
   end

   jump.subspec 'Navigator' do |nav|
        nav.dependency 'jump2/Core'
        nav.dependency 'SOCKit'
	    nav.source_files = 'src/navigator/*.{h,m}'
   end

end
