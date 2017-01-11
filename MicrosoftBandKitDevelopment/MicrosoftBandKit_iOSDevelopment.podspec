Pod::Spec.new do |s|
  s.name     = 'MicrosoftBandKit_iOSDevelopment'
  s.version  = '1.0.0'
  s.platform = :ios, '8.0'
  s.summary  = 'MicrosoftBandKit with private headers'
  s.homepage = 'http://example.com'
  s.author   = { 'Anton Sokolchenko' => 'wsevendays@gmail.com' }
  s.license      = { "MIT" }
  s.requires_arc = true
  s.vendored_frameworks = 'MicrosoftBandKit_iOS.framework'
  s.source   = { :git => 'https://github.com/me/MyInternalLibrary.git', :tag => s.version.to_s }
  s.subspec 'sources' do |ss|
        ss.source_files = '*.{h,m}'
  end
end
