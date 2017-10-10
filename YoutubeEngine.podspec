Pod::Spec.new do |s|
  s.name             = 'YoutubeEngine'
  s.version          = '0.3.0'
  s.summary          = 'Swift ReactiveCocoa lib for Youtube api.'

  s.description      = <<-DESC
Swift library for searching Youtube channels and videos
                       DESC

  s.homepage         = 'https://github.com/Igor-Palaguta/YoutubeEngine'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Igor Palaguta' => 'igor.palaguta@gmail.com' }
  s.source           = { :git => 'https://github.com/Igor-Palaguta/YoutubeEngine.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/igor_palaguta'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/YoutubeEngine/**/*'

  s.dependency 'ReactiveSwift', '~> 2.0'
  s.dependency 'SwiftyJSON', '~> 3.1.4'
end
