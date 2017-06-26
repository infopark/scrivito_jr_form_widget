module ScrivitoCrmFormWidget
  class Configuration
    attr_accessor :hidden_attributes

    def initialize
      @hidden_attributes = ['origin','referrer','tracking','service']
    end
  end
end
