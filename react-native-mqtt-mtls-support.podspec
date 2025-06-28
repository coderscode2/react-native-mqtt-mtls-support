Pod::Spec.new do |s|
  s.name         = "react-native-mqtt-mtls-support"
  s.version      = "0.1.0"
  s.summary      = "MQTT with mTLS support for React Native"
  s.authors      = { "Ved Yedla" => "veda59@gmail.com" }
  s.homepage     = "https://github.com/coderscode2/react-native-mqtt-mtls-support"
  s.license      = "MIT"
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/coderscode2/react-native-mqtt-mtls-support.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  # ✅ Core dependencies
  s.dependency 'CocoaMQTT'
  s.dependency 'React-Core'

  # ✅ Framework needed for SSL constants like `kCFStreamSSLTrustedRoots`
  s.frameworks = 'CFNetwork'

  # ✅ Swift version compatibility
  s.swift_version = '5.0'
end
