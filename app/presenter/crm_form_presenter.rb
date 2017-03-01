class CrmFormPresenter
  include ActiveModel::Model

  def attribute_names
    @type.standard_attrs.keys + @type.custom_attrs.keys
  end

  def initialize(widget, request, controller)
    @widget = widget
    @activity = widget.activity
    @page = widget.obj
    @params = request.params["crm_form_presenter"]
    @dynamic_params = set_dynamic_params
    errors = validate_params

    if errors.present?
      return {status: "error", message: errors}
    elsif request.post? && widget.id == @params[:widget_id]
      redirect_after_submit(controller, widget, self.submit)
    end
  end

  def submit
    if @params['email'].present?
      raise 'No human exeception'
    else
      @params.delete('email')
    end
    prepare_contact(@params['custom_email'], @params['custom_last_name'])
    prepare_activity_params
    Crm::Activity.create(@params)
    return {status: "success", message: "Your form was send successfully"}
  rescue Crm::Errors::InvalidValues => e
    return {status: "error", message: e.validation_errors}
  end

  private
  def prepare_activity_params
    @params[:comment_notes] = @dynamic_params if @dynamic_params.present?

    @params.delete("widget_id")
    @params["title"] = @params[:title].empty? ? @activity.id : @params[:title]
    @params["type_id"] = @activity.id
    @params["state"] = @activity.attributes['states'].first
  end

  def set_dynamic_params
    dynamic_params = {};
    @params.each do |key, value|
      if key.starts_with? 'dynamic_'
        dynamic_params[key] = value
        @params.delete(key)
      end
    end
    return dynamic_params
  end


  def prepare_contact(email, last_name)
    if email && last_name
      contact = manipulate_or_create_user(email, last_name)
      if contact
        set_params_for_activty(contact)
        add_contact_to_event(contact) if @widget.event_id.present?
      end
    end
  end

  def manipulate_or_create_user(email, last_name)
    contact = Crm::Contact.where(:email, :equals, email).and(:last_name, :equals, last_name).first
    unless contact
      contact = Crm::Contact.create({
        first_name: @params['custom_first_name'],
        last_name: @params['custom_last_name'],
        email: @params['custom_email'],
        language: 'de'
      })
    end

    add_tags_to(contact)

    return contact
  end

  def add_contact_to_event(contact)
    Crm::EventContact.create({
      contact_id: contact.id,
      event_id: @widget.event_id,
      state: 'registered'
    })
  end

  def add_tags_to(contact)
    if @widget.tags
      tags = contact.tags + @widget.tags.split("|")
      contact.update({tags: tags})
    end
  end

  def set_params_for_activty(contact)
    if @params["title"] == ""
      @params["title"] = @activity.id
    end

    @params["contact_ids"] = contact.id
  end

  def redirect_path(page, widget)
    obj = redirect_obj(page, widget)
    obj.binary? ? obj.try(:binary_url) : "/#{obj.id}"
  end

  def redirect_obj(page, widget)
    (widget.respond_to?('redirect_to') && widget.redirect_to.present?) ? widget.redirect_to : page
  end

  def redirect_after_submit(controller, widget, submit_message)
    if submit_message[:status] == "success"
      controller.redirect_to(redirect_path(@page, widget), notice: submit_message[:message])
    elsif submit_message[:status] == "error"
      controller.redirect_to("/#{@page.id}", alert: submit_message[:message])
    end
  end

  def validate_params
    email = validate_email(@params['custom_email'])
    hook = Obj.respond_to?('crm_form_validation') ? Obj.crm_form_validation(@params) : false
    email || hook
  end

  def validate_email(email)
    email.present ? /.+@.+\..+/i.match(email).present? : false
  end
end
