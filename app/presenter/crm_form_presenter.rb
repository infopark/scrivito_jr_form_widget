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
    @access_code = generate_random_string(12)
    errors = (request.post? || !@params.nil?) ? validate_params : nil

    if errors.present?
      controller.redirect_to("/#{@page.id}", alert: { status: "error", message: errors, widget_id: @widget.id })
    elsif request.post? && widget.id == @params[:widget_id]
      request.session['access_via_form'] = @access_code
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

    Obj.crm_form_before_send_hook(@params, @activity) if Obj.respond_to?('before_send_hook')

    Crm::Activity.create(@params)
    return {status: "success", message: "Your form was send successfully"}
  rescue Crm::Errors::InvalidValues => e
    return {status: "error", message: e.validation_errors}
  end

  private
  def prepare_activity_params
    @params[:comment_notes] = @dynamic_params if @dynamic_params.present?
    @params[:comment_attachments] = [@params[:custom_file]] if @params[:custom_file].present?

    if @params[:custom_file].present?
      @params.delete(:custom_file)
    end

    @params.delete('access_via_form')
    @params.delete("widget_id")
    @params["title"] = @params[:title].empty? ? @activity.id : @params[:title]
    @params["type_id"] = @activity.id
    @params["state"] = @activity.attributes['states'].first
  end

  def set_dynamic_params
    dynamic_params = {};
    (@params || []).each do |key, value|
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
    obj.binary? ? obj.try(:binary_url) : "/#{obj.id}?access_via_form=#{@access_code}"
  end

  def redirect_obj(page, widget)
    (widget.respond_to?('redirect_to') && widget.redirect_to.present?) ? widget.redirect_to : page
  end

  def redirect_after_submit(controller, widget, submit_message)
    if submit_message[:status] == "success"
      controller.redirect_to(redirect_path(@page, widget), notice: [submit_message[:message]])
    elsif submit_message[:status] == "error"
      controller.redirect_to("/#{@page.id}", alert: [submit_message[:message]])
    end
  end

  def validate_params
    email = valid_email?(@params['custom_email']) ? [] : [{attribute: 'custom_email', message: 'The email is not a valid email address.', code: 'email'}]
    hook = Obj.respond_to?('crm_form_validation_hook') ? Obj.crm_form_validation_hook(@params, @widget) : []
    crm = @widget.validate(@params)

    email + hook + crm
  end

  def valid_email?(email)
    /.+@.+\..+/i.match(email).present?
  end

  def generate_random_string(length = 8)
    [*('a'..'z'),*('0'..'9')].shuffle[0,length].join
  end
end
