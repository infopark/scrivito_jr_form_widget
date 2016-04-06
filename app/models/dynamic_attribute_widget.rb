class DynamicAttributeWidget < Widget
  attribute :title, :string
  attribute :label, :string
  attribute :type, :enum, values: ['string','text','enum','multienum'], default: 'string'
  attribute :valid_values, :stringlist
  attribute :maxlength, :string, default: 100

  def self.valid_container_classes
    [CrmFormWidget]
  end

  def options
    {
      'valid_values' => valid_values,
      'maxlength' => maxlength
    }
  end

  def field_name
    field = title.parameterize('_')
    return "dynamic_#{field}"
  end
end
