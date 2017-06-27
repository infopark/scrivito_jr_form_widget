# ScrivitoCrmFormWidget

A Scrivito widget for adding a form based on an Infopark CRM activity type to a page.

## Installation

Add this line to your application's Gemfile:

    gem 'scrivito_crm_form_widget'

Add this line to your stylsheet manifest:

    *= require scrivito_crm_form_widget

Add this line to your JavaScript manifest:

    //= require scrivito_crm_form_widget

## Features

If the selected activity type has the fields `email` and `last_name`, a CRM contact based on this data is searched for, and, if it doesn't exist, is created.

The editor may also select an event on the details view of the widget. If the `email` and `last_name` fields exist, a corresponding CRM contact is be added to the event as an event contact.

## Localization

The following code represents the default localization for English. Copy it to your `en.yml` and change it if necessary:

```yaml
en:
  scrivito_crm_form_widget:
    thumbnail:
      title: CRM Form
      description: Add a formular to your page based on an activty from Infopark CRM
    details:
      activity_id:  Activity
      event_id: Event
      subject: Subject
      tags: Tags
      redirect_to: Redirect after submit
      submit_button_text: Text on Submit button
      dynamic_attribute: Attribute
      title: Title
      label: Label
      type: Type
      valid_values: Values
      maxlength: Max Length
      label_position: Label Position
      columns: Columns
      file_upload: File upload
      styles: Styles
      multilevel: Is a multilevel form
      attributes: Attributes for this level
    view:
      file: File upload
```

You can loaclize your labels using i18n:

```yaml
en:
  helpers:
    label:
      crm_form_presenter:
        custom_attribute_1: Foo
        custom_attribute_2: Bar
        custom_enum_attribute: Enum
        custom_enum_attribute_options:
          one: One
          two: Two
          three: Three
```

You can also set locals for a placeholder. This is only available for Text and Textarea fields:

```yaml
en:
  helpers:
    placeholder:
      crm_form_presenter:
        custom_attribute_1: Foo
        custom_attribute_2: Bar
        custom_enum_attribute: Enum
        custom_enum_attribute_options:
          one: One
          two: Two
          three: Three
```

## Customization

A field label is given the `mandatory` class if the field is marked as mandatory in the activity type. You can style this using CSS, for example:

```css
label.mandatory:after {
  content: "*";
}
```

If the creation of a new activity fails, the `flash[:alert]` value is set. The message returned bythe CRM SDK is used as the flash message. It has the following format:

```ruby
[
  {
    "attribute" => "gender",
    "code" => "inclusion",
    "message" => "gender is not included in the list: unknown, male, female"
  },
  {
    "attribute" => "language",
    "code" => "inclusion",
    "message" => "language is not included in the list"
  },
  {
    "attribute" => "last_name",
    "code" => "blank",
    "message" => "last_name can't be blank"
  }
]
```

You can use this to create a message for the user.

If you are maintaining the activities of severeal websites with a single Infopark CRM, you can add the 'self.crm_activity_filter' method to your obj.rb file to filter the activity types by your selection criteria.

```ruby
def self.crm_activity_filter
  Crm::Type.all.select { |a| a.id.starts_with? 'page-' }
end
```

Using advance editors, you can define the selectable classes by adding a class method to your `obj.rb`:

```ruby
  class Obj < Scrivito::BasicObj
    ...
    def self.scrivito_selectable_style_classes(class_name='')
      if class_name == 'CrmFormWidget'
        ['special_style', ...]
      else
        ...
      end
    end
    ...
  end
```

Than you have to define a css class for your selections:

```css
  form.special_style {
    border: 1px solid red;
  }
```

#### Configuration

Create an initializer and add the following:

```ruby
# in your initializer

ScrivitoCrmFormWidget.configure do |config|
  config.hidden_attributes = ['origin','referrer','tracking','service']
end
```

`hidden_attributes` contains all your crm attributes that will be rendered as hidden fields. They will be filled with a parameter in your url. Be aware that you do not add `custom_` to the values. To save your attribute in an activity, add it to the type configuration. In a link to the page with the form, add the parameter, e.g. `https://your_page.com/page_with_form?origin=facebook`.

### Attributes

#### Activity

Lets you select an activity type from the available ones.

#### Subject

This is used as the title of a created activity.

#### Tags

If the activity type has the fields `email` and `last_name`, a CRM contact based on this data is searched for, if it doesn't exist, it is created. If tags have been specified they are added to the contact.

#### Redirect after submission

On the details view a redirection target, which becomes effective after submitting the form, can be specified.

#### Text on submission button

The text to display on the submission button. The default is `send`.

## Advanced Stuff

### Creating a survey

You can use the CRM Form Widget gem for a poll with different steps. For this, activate the `multilevel` function in the details view and add the functionality to your app:

First add a style class to your forms to use for differntiating:

```ruby
# in obj.rb
def self.scrivito_selectable_style_classes(class_name='')
  if class_name == "CrmFormWidget"
    ['survey_form', ...]
  else
    ...
  end
end
```

Create your JavaScript code for the click handler:

```javascript
(function($, app) {
  'use strict';

  scrivito.on('content', function(content) {
    var form = $('.survey_form');
    var fieldsets = form.find('fieldset');
    var prev = $('<div class="prev btn btn-lg bg-gray pull-left"><i class="fa fa-chevron-left"></i></div>')
    var next = $('<div class="next btn btn-lg bg-blue pull-right">Weiter</div>')
    var max_height = fieldsets.sort(function(a,b) { return $(b).height() - $(a).height() }).first().height();

    form.append(prev);
    form.append(next);
    form.find('fieldset').first().addClass('active');
    fieldsets.css('height', max_height + 'px');

    form.on('click', '.next', function() {
      var active = form.find('.active');
      var next_slide = active.next('fieldset');
      if(next_slide.length > 0) {
        next_slide.addClass('active');
        active.removeClass('active');
      }
    });

    form.on('click', '.prev', function() {
      var active = form.find('.active');
      var next_slide = active.prev('fieldset');
      if(next_slide.length > 0) {
        next_slide.addClass('active');
        active.removeClass('active');
      }
    });
  });
})(jQuery, this);
```

Add some Css to hide all field sets and basic styling:

```css
.survey_form {
  .crm-form-widget-multilevel fieldset {
    display: none;
    &.active {
      display: block;
    }
  }

  .prev {
    cursor: pointer;
  }

  .next {
    width: 200px;
    max-width: 100%;
    cursor: pointer;
  }

  .form-submit-button-container .btn {
    float: none !important;
    display: block;
    margin: 0 auto;
    min-width: 200px;
  }
}
```

### Adding a protection to a page

The form generates a random string to create an access code that can be used to check if a request on a page is initiated by a sent form.

To check this you can compare the `session['access_via_form']` with `params['access_via_form']` in your controller.

```ruby
#in page_controller.rb
class PageController < Obj
  def index
    if !scrivito_in_editable_view? && !page_is_accessable?
      raise Scrivito::ResourceNotFound.new('Not Found')
    end
  end

  def page_is_accessable?
    !@obj.direct_access_is_protected? || (@obj.direct_access_is_protected? && form_was_filled?)
  end

  def form_was_filled?
    session['access_via_form'].present? && (session['access_via_form'] == params['access_via_form'])
  end
end

# in obj.rb
class Obj < Scrivito::BasicObj
  ...
  def direct_access_is_protected?
    # when should the protection be used
  end
  ...
end
```
