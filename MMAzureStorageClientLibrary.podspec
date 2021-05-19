#
# Be sure to run `pod lib lint MMAzureStorageClientLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMAzureStorageClientLibrary'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MMAzureStorageClientLibrary.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/huy-luvapay/MMAzureStorageClientLibrary.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huy-luvapay' => 'huy.van@epapersmart.com' }
  s.source           = { :git => 'https://github.com/huy-luvapay/MMAzureStorageClientLibrary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '10.0'

  s.swift_version = '5.0'

  s.source_files = 'MMAzureStorageClientLibrary/Classes/**/*.{h,m,mm,swift}'
  
  s.requires_arc = true
  
  s.resources = [
    'MMAzureStorageClientLibrary/Assets/**/*.png',
    'MMAzureStorageClientLibrary/Classes/**/*.bundle',
    'MMAzureStorageClientLibrary/Classes/**/*.xib',
    'MMAzureStorageClientLibrary/Classes/**/*.storyboard',
    "MMAzureStorageClientLibrary/Assets/**/*.lproj"
  ]
  
end
