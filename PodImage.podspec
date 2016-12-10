
Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '10.0'

  s.name         = "PodImage"
  s.version      = "1.0.11"
  s.summary      = "PodImage classes"
  s.description  = <<-DESC
  A bunch of classes i have found useful for PodImage
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Etienne Goulet-Lang" => "" }
  s.source       = { :git => "https://github.com/egouletlang/PodImage.git", :tag => "#{s.version}" }

  s.homepage = "https://github.com/egouletlang/PodImage"

  s.source_files  = "PodImage", "PodImage/**/*.{h,m}", "PodImage/**/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  s.dependency 'BaseUtils'

end

