$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scrivito_crm_form_widget/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scrivito_crm_form_widget"
  s.version     = ScrivitoCrmFormWidget::VERSION
  
  s.authors     = ["Scrivito"]
  s.email       = ["support@scrivito.com"]
  s.homepage    = "https://www.scrivito.com"
  
  s.summary     = "A widget for Scrivito to show a form using crm 2.0 api."
  s.description = "A widget for Scrivito to show a form using crm 2.0 api."
  s.license     = "LGPL-3.0"
  
  s.files = Dir[
    "{app,lib,scrivito}/**/*",
    "LICENSE",
    "Rakefile"
  ]

  s.add_dependency 'bundler'
  s.add_dependency 'scrivito_sdk'
  s.add_dependency 'scrivito_advanced_editors'
  s.add_dependency 'active_attr'

  s.add_development_dependency 'rake'
end
