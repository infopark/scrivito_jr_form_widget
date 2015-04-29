class CrmFormWidget < Widget
  include Crm

  attribute :activity_id, :string
  attribute :event_id, :string
  attribute :subject, :string
  attribute :tags, :string
  attribute :redirect_to, :reference
  attribute :submit_button_text, :string

  def self.activities
    Obj.try(:crm_activity_filter) || Crm::Type.all.select {|i| i.item_base_type == "Activity"}
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

  def submit_button
    submit_button_text.present? ? submit_button_text : "send"
  end

  def self.events
    Obj.try(:crm_activity_filter) || Crm::Event.all.to_a
  end
end