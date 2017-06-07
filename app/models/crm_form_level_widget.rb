class CrmFormLevelWidget < Widget
  attribute :fields, :stringlist
  attribute :headline, :string

  def self.valid_container_classes
    [CrmFormWidget]
  end

  def attributes
    Hash[fields.map {|f| [f, container.attributes[f]] }]
  end

  def selectable
    elems = container.attributes.map(&:first)
    return elems
  end
end
