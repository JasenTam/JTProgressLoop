#
#  Be sure to run `pod spec lint JTRedDot.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "JTProgressLoop"
  s.version      = "1.0.2"
  s.summary      = "A Progress Loop."

  s.description  = <<-DESC
  A Progress Loop, very easy to use.
                   DESC

  s.homepage     = "https://github.com/JasenTam/JTProgressLoop"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "JTam" => "48782442@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/JasenTam/JTProgressLoop.git", :tag => "#{s.version}" }

  s.source_files  = "JTProgressLoop", "JTProgressLoop.{h,m}"
  s.exclude_files = "JTProgressLoop/Exclude"

  s.requires_arc = true

end
