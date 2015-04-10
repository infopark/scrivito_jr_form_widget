class JrFormWidget < Widget
  include JustRelate

  def self.activities
    Obj.try(:jr_activity_filter) || JustRelate::Type.all.to_a
  end

  def attributes
    activity.attribute_definitions
  end

  def activity
    JustRelate::Type.find(activity_id)
  end

  def activity_id?
    self.activity_id != ""
  end

  def submit_button
    submit_button_text.present? ? submit_button_text : "send"
  end
end