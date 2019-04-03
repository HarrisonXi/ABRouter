Pod::Spec.new do |s|
  s.name         = 'ABRouter'
  version        = '0.1'
  s.version      = version
  s.summary      = 'URL Router with ABTest feature for iOS.'
  s.homepage     = 'https://github.com/HarrisonXi/ABRouter'
  s.license      = { :type => 'MIT' }
  s.author       = { 'HarrisonXi' => 'gpra8764@gmail.com' }
  s.platform     = :ios, '8.0'
  s.source       = { :git => 'https://github.com/HarrisonXi/ABRouter.git', :branch => 'master' }
  s.source_files = 'ABRouter/*.{h,m}'
end
