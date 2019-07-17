Pod::Spec.new do |s|
  s.name             = 'VolansysComponent'
  s.version          = '0.0.1'
  s.summary          = 'Volansys Component easy to use for your daily work'
 
  s.description      = <<-DESC
Volansys Component easy to use for your daily work test
                       DESC
 
  s.homepage         = 'https://github.com/mirantvolansys/VolansysComponent'
  s.license          = { :type => 'Mirant', :file => 'LICENSE' }
  s.author           = { 'Mirant' => 'mirant.patel@volansys.com' }
  s.source           = { :git => 'https://github.com/mirantvolansys/VolansysComponent.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '11.0'
  s.source_files = 'Utility/*'
 
end