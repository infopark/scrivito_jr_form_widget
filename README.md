# ScrivitoCrmFormWidget

A Scrivito widget for adding a form based on an Infopark CRM activity type to a page.

## Installation

Add this line to your application's Gemfile:

    gem 'scrivito_crm_form_widget'

Add this line to your stylsheet manifest:

    *= require scrivito_crm_form_widget

Add this line to your JavaScript manifest:

    //= require scrivito_crm_form_widget

Create a model named `JrFormAttribtues` for use by the presenter to make your custom attributes accessible to the form:

```ruby
class CrmFormAttributes
  include ActiveModel::Model

  attr_accessor :custom_attribute_1, :custom_attribute_2, ...
end
```

## Features

If the selected activity type has the fields `email` and `last_name`, a CRM contact based on this data is searched for, and, if it doesn't exist, is created.

The editor may also select an event on the details view of the widget. If the `email` and `last_name` fields exist, a corresponding CRM contact is be added to the event as an event contact.

## Localization

You can loaclize your labels using i18n:

```yml
en:
  helpers:
    label:
      crm_form_presenter:
        custom_attribute_1: 'Foo'
        custom_attribute_2: 'Bar'
        custom_enum_attribute: 'Enum'
        custom_enum_attribute_options:
          one: 'One'
          two: 'Two'
          three: 'Three
```

## Customization

A field label is given the `mandatory` class if the field is marked as mandatory in the activity type. You can style this using CSS, for example:

    label.mandatory:after {
      content: "*";
    }

If the creation of a new activity fails, the `flash[:alert]` value is set. The message returned bythe CRM SDK is used as the flash message. It has the following format:

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

You can use this to create a message for the user.

If you are maintaining the activities of severeal websites with a single Infopark CRM, you can add the 'self.crm_activity_filter' method to your obj.rb file to filter the activity types by your selection criteria.

    def self.crm_activity_filter
      Crm::Type.all.select { |a| a.id.starts_with? 'page-' }
    end

### Attributes

#### Activity

Lets you select an activity type from the available ones.

#### Subject

This is used as the title of a created activity.

#### Tags

If the activity type has the fields named `email` and `last_name`, a CRM contact based on this data is searched for, and, if it doesn't exist, is created. If tags have been specified, they are added to the contact.

#### Redirect after submission

On the details view a redirection target, which becomes effective after submitting the form, can be specified.

#### Text on submission button

The text to display on the submission button. The default is `send`.
