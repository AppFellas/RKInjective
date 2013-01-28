Pod::Spec.new do |s|
  s.name     = 'RKInjective'
  s.version  = '0.0.1'
  s.platform = :ios, '5.0'
  s.license = 'MIT'
  s.summary  = 'iOS library for bootstrapping model loading with RestKit.'
  s.homepage = 'https://github.com/AppFellas/RKInjective'
  s.authors   = {
    'Taras Kalapun' => 'http://kalapun.com'
  }
  s.source   = { :git => 'https://github.com/AppFellas/RKInjective.git' }
  s.source_files = 'RKInjective/*.{h,m}'
  s.requires_arc = true
  s.dependency 'RestKit'
  s.dependency 'Inflections'
end
