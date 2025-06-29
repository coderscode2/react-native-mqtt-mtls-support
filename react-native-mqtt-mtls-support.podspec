Pod::Spec.new do |s|
  s.name         = "react-native-mqtt-mtls-support"
  s.version      = "0.2.0"
  s.summary      = "MQTT with mTLS support for React Native"
  s.authors      = { "Ved Yedla" => "veda59@gmail.com" }
  s.homepage     = "https://github.com/coderscode2/react-native-mqtt-mtls-support"
  s.license      = "MIT"
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/coderscode2/react-native-mqtt-mtls-support.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift,c}"
  s.requires_arc = true

  s.dependency 'React-Core'
  s.dependency 'OpenSSL-Universal'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/ios/CSRModule',
    'OTHER_CFLAGS' => '-fmodules',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

  s.module_map = 'ios/CSRModule/module.modulemap'
  s.header_mappings_dir = 'ios'

  # ✅ Required to avoid build errors with Swift + custom module map
  s.static_framework = false
end
