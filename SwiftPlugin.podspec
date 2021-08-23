Pod::Spec.new do |s|
  s.name          = "SwiftPlugin"
  s.version       = "0.0.1"
  s.summary       = "iOS SDK for Bluetooth connection"
  s.description   = "iOS SDK for Bluetooth connection, including example app"
  s.homepage      = "https://github.com/kiet1993/"
  s.license       = "MIT"
  s.author        = "kietlt"
  s.platform      = :ios, "11.0"
  s.swift_version = "5.0"
  s.source        = {
    :git => "https://github.com/peteranny/HelloWorldSDK.git",
    :tag => "#{s.version}"
  }
  s.source_files        = "SwiftPlugin/**/*.{h,m,swift}"
  s.public_header_files = "SwiftPlugin/**/*.h"
end