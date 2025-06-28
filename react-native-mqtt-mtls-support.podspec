Pod::Spec.new do |s|
  s.name         = "react-native-mqtt-mtls-support"
  s.version      = "0.1.0"
  s.summary      = "MQTT with mTLS support for React Native"
  s.authors      = { "Your Name" => "you@example.com" }
  s.homepage     = "https://github.com/your/repo"
  s.license      = "MIT"
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/your/repo.git", :tag => "#{s.version}" }
  s.source_files  = "ios/**/*.{h,m,swift}"
  s.requires_arc = true
end
