require "scrivito_crm_form_widget/engine"
require "scrivito_crm_form_widget/configuration"

module ScrivitoCrmFormWidget
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
