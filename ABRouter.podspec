Pod::Spec.new do |spec|
  spec.name         = 'ABRouter'
  version           = '0.1'
  spec.version      = version
  spec.summary      = 'URL Router with ABTest feature for iOS.'
  spec.homepage     = 'https://github.com/HarrisonXi/ABRouter'
  spec.license      = { :type => 'MIT' }
  spec.author       = { 'HarrisonXi' => 'gpra8764@gmail.com' }
  spec.platform     = :ios, '8.0'
  spec.source       = { :git => 'https://github.com/HarrisonXi/ABRouter.git', :branch => 'master' }
  spec.source_files = 'ABRouter/*.{h,m}'
  spec.private_header_files = 'ABRouter/ABRouteMap.h'
end
