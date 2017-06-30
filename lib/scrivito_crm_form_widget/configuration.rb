module ScrivitoCrmFormWidget
  class Configuration
    attr_accessor :hidden_attributes
    attr_accessor :show_error_message
    attr_accessor :as_select_field

    def initialize
      @hidden_attributes = ['origin','referrer','tracking','service']
      @show_error_message = true
      @as_select_field = 4
    end
  end
end
