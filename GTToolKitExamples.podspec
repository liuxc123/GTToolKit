Pod::Spec.new do |s|
  s.name             = 'GTToolKitExamples'
  s.version          = '0.0.1'
  s.summary          = 'GTToolKit Demo库'
  s.homepage         = 'https://github.com/liuxc123/GTToolKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuxc123' => 'lxc_work@126.com' }
  s.source           = { :git => 'https://github.com/liuxc123/GTToolKit.git', :tag => s.version.to_s }
  s.requires_arc = true

  # Conventions
  s.source_files = 'components/*/examples/*.{h,m,swift}', 'components/*/examples/supplemental/*.{h,m,swift}'
  s.resources = ['components/*/examples/resources/**/*']
  s.public_header_files = 'components/*/examples/*.h', 'components/*/examples/supplemental/*.h'


  s.dependency 'GTToolKit'
end
