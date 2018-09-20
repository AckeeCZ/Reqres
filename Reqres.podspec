Pod::Spec.new do |s|
  s.name             = 'Reqres'
  s.version          = '3.0.0'
  s.summary          = 'Simple network activity logger'
  s.description      = <<-DESC
Logs every request app makes, works great with Alamofire.
                       DESC
  s.homepage         = 'https://github.com/AckeeCZ/Reqres'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ackee' => 'info@ackee.cz' }
  s.source           = { :git => 'https://github.com/AckeeCZ/Reqres.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
  s.source_files = 'Reqres/*.swift'
end
