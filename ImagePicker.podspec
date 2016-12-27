Pod::Spec.new do |s|
s.name                = 'ImagePicker'
s.version             = '1.0.0'
s.summary             = 'ImagePicker'
s.license             = 'Copyright © 2012-2015 TBXark'
s.author              = { "TBXark" => "tbxark@outlook.com" }
s.license             = { :type => "Copyright", :text => "©2016 TBXark"}
s.requires_arc        = true
s.platform            = :ios, '8.0'
s.homepage            = 'http://tbxark.site'
s.source              = { :http => "http://img.playalot.cn/AlibabaSDK-1.2.161026.zip" }
s.frameworks          = 'UIKit','Photos'
s.resources           = 'ImagePicker/Resource/Image.bundle'
s.source_files        = 'ImagePicker/**/*.{h,swift}'


end
