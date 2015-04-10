class JrFormPresenter < JrFormAttributes

  def attribute_names
    @type.standard_attrs.keys + @type.custom_attrs.keys
  end

  def initialize(widget, request, controller)
    @widget = widget
    @activity = widget.activity
    @page = widget.obj
    @params = request.params["jr_form_presenter"]

    if request.post?
      redirect_after_submit(controller, widget, self.submit)
    end
  end

  def submit
    contact = nil
    
    if @params['custom_email'] && @params['custom_last_name']
      contact = manipulate_or_create_user
    end

    if contact
      set_params_for_activty(contact)
    end

    @params["title"] = @params[:title].empty? ? @activity.id : @params[:title]
    @params["type_id"] = @activity.id
    @params["state"] = @activity.attributes['states'].first

    activity = JustRelate::Activity.create(@params)

    return {status: "success", message: "Your form was send successfully"}
  rescue JustRelate::Errors::InvalidValues => e
    return {status: "error", message: e.validation_errors}
  end

  private
  def manipulate_or_create_user
    contact = JustRelate::Contact.where(:email, :equals, @params['custom_email']).and(:last_name, :equals, @params['custom_last_name']).first
    unless contact
      contact = JustRelate::Contact.create({
        first_name: @params['custom_first_name'],
        last_name: @params['custom_last_name'],
        email: @params['custom_email'],
        language: 'de'
      })
    end

    add_tags_to(contact)

    return contact
  end

  def add_tags_to(contact)
    tags = contact.tags + @widget.tags.split("|")
    contact.update({tags: tags})
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
end
