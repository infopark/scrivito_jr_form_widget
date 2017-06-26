class CrmFormWidget < Widget
  include Crm

  attribute :activity_id, :string
  attribute :event_id, :string
  attribute :subject, :string
  attribute :tags, :string
  attribute :redirect_to, :reference
  attribute :submit_button_text, :string
  attribute :dynamic_attributes, :widgetlist
  attribute :label_position, :enum, values: ['left','top'], default: 'left'
  attribute :columns, :enum, values: ['one','two'], default: 'one'

  attribute :multilevel, :enum, values: ['Yes','No'], default: 'No'
  attribute :levels, :widgetlist
  attribute :multilevel_dynamic, :string, default: 'More attributes'
  attribute :multilevel_file, :string, default: 'File upload'
  attribute :multilevel_send, :string, default: 'Send'

  attribute :file_upload, :enum, values: ['Yes','No'], default: 'No'
  attribute :styles, :stringlist

  def scrivito_selectable_style_classes
    if Obj.respond_to? 'scrivito_selectable_style_classes'
      Obj.scrivito_selectable_style_classes('CrmFormWidget')
    else
      []
    end
  end

  def valid_widget_classes_for(field_name)
    [field_name == 'levels' ? CrmFormLevelWidget : DynamicAttributeWidget]
  end

  def self.activities
    @activities ||= Obj.try(:crm_activity_filter) || Crm::Type.all.select {|i| i.item_base_type == "Activity"}
  end

  def attributes
    activity.attribute_definitions
  end

  def activity
    Crm::Type.find(activity_id)
  end

  def activity_id?
    self.activity_id != ""
  end

  def multilevel?
    multilevel == 'Yes'
  end

  def submit_button
    submit_button_text.present? ? submit_button_text : "send"
  end

  def self.events
    @events ||= Obj.try(:crm_activity_filter) || Crm::Event.all.to_a
  end

  def self.event_ids
    CrmFormWidget.events.map {|e| e.id}
  end

  def self.event_names
    name_hash = {}
    CrmFormWidget.events.each do |e|
      name_hash[e.id] = e.title
    end
    return name_hash
  end

  def self.activity_ids
    CrmFormWidget.activities.map {|a| a.id}
  end

  def field_as_select?(options)
    columns == 'two' || options['valid_values'].count > 4
  end

  def file_upload?
    file_upload == 'Yes'
  end

  def placeholder(field)
    local = "helpers.placeholder.crm_form_presenter.#{field}"
    I18n.exists?(local) ? I18n.t(local) : nil
  end

  def hidden?(name, options, request)
    param_given = !options[:visible_in_form] && request.params[name.sub(/^custom_/,'')].present?
    param_given || ScrivitoCrmFormWidget.configuration.hidden_attributes.include?(name.sub(/^custom_/,''))
  end
end
