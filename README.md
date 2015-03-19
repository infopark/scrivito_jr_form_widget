# scrivito_jr_form_widget

## Description

A Widget for Scrivito to add an formular based on an activity type from Justrelate using API 2.

## Editor usage

Insert Widget. Initaly the editor will see a note telling him he has to select a type on details view.

### Attributes

#### Activity

Is a toggle button select from all types in your Just Relate CRM.

#### Subject

Will be used as title at an created activty. You can use the same type on different pages in different situations. Like event subscribtions.

#### Tags

If your type have the fields `custom_email` and `custom_last_name` a contact from crm can by found. If tags are set they will be add to the contact. So you can see if a contact has filled in a special from like newsletter subscription or event subscription.

#### Redirect after submit

If set the formsubmit will redirect to the given page. If the specified obj is a binary object, it will redirect to its binary_url. If not set, the form will redirect to the page where it is on.

This Feature can be used to create a soft way for getting Seminar Downloads where you want a feedback.

#### Text on submit button

Writes the text to hte submit button. Default is `send`.

## Installation

Add this lines to your application's `Gemfile`:

    gem 'scrivito_jr_form_widget'
    gem 'scrivito_advanced_editors'
    gem 'active_attr'

You need a Model with name `JrFormAttribtues`. It is used by the presenter to make your custom attributes accessible by the form. You can define prefill values here.

    class JrFormAttributes
      include ActiveModel::Model

      attr_accessor :custom_attribute_1, :custom_attribute_2, ...

      def custom_attribute_3
        "My Prefill Value"
      end
    end

The label of every field gets the class `mandatory` if the field is marked as mandatory in the activity. You can style this with css, for example:

    label.mandatory:after {
      content: "*";
    }

If the creation of a new activity fails at a form submit, the `flash[:alert]` value is set. Just Relate SDK message will used as flash message. It will look like:

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

And then execute:

    $ bundle
    $ rake scrivito:migrate:install
    $ rake scrivito:migrate
    $ rake scrivito:migrate:publish

Using more than one Page and activities should be seperated. You can add a hook with your separation strategy. Simply add the method `self.jr_activity_filter` to your obj.rb.

    def self.jr_activity_filter
      JustRelate::Type.all.select { |a| a.id.starts_with? 'page-' }
    end

This will select activities by its id.

## Contributing

1. Fork it ( https://github.com/scrivito/scrivito_icon_box_widget/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request