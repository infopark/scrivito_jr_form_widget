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

  s.summary     = "A widget for Scrivito to show a form using Infopark CRM api v2.0."
  s.description = "A widget for Scrivito to show a form using Infopark CRM api v2.0."
  s.license     = "LGPL-3.0"

  s.files = Dir[
    "{app,lib,scrivito}/**/*",
    "LICENSE",
    "Rakefile"
  ]

  s.add_dependency 'scrivito'
  s.add_dependency 'scrivito_advanced_editors'
  s.add_dependency 'active_attr'
  s.add_dependency 'infopark_webcrm_sdk'
end
