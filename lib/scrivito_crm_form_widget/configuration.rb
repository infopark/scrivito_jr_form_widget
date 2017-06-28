module ScrivitoCrmFormWidget
  class Configuration
    attr_accessor :hidden_attributes
    attr_accessor :show_error_message

    def initialize
      @hidden_attributes = ['origin','referrer','tracking','service']
      @show_error_message = true
    end
  end
end
