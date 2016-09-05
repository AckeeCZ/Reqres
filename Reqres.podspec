#
# Be sure to run `pod lib lint Reqres.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reqres'
  s.version          = '1.2.0'
  s.summary          = 'Simple network activity logger'

  s.description      = <<-DESC
Logs every request app makes, works great with Alamofire.
                       DESC

  s.homepage         = 'https://github.com/AckeeCZ/Reqres'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ackee' => 'info@ackee.cz' }
  s.source           = { :git => 'https://github.com/AckeeCZ/Reqres.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Reqres/Classes/**/*'
end
