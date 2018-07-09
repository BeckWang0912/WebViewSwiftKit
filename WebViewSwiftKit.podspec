Pod::Spec.new do |s|

  s.name         = "WebViewSwiftKit"
  s.version      = "0.0.1"
  s.summary      = "more lightweight, simple to load webview, and defines how javascript interacts with native apps."
  s.homepage     = "https://github.com/BeckWang0912/WebViewSwiftKit"
  s.license      = { :type => "MIT", :file => "LICENSE" } 
  s.description  = <<-DESC 
                        `WebView`  This tool set is more lightweight, simple to load webview, and defines how javascript interacts with native apps.
                   DESC
  s.author       = { "IMAC-AF9B8D" => "2067431781@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/BeckWang0912/WebViewSwiftKit.git", :tag => 'v'+s.version.to_s}
  s.source_files = 'Source/**/*.{h,m,swift}'
  s.resources = "Source/resource.bundle"
  s.dependency ["SnapKit", "WebViewJavascriptBridge"]
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

end