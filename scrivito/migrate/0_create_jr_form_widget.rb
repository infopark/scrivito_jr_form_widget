class CreateJrFormWidget < ::Scrivito::Migration
  def up
    Scrivito::ObjClass.create(
      name: 'JrFormWidget',
      type: 'publication',
      title: 'Just Relate Fromular Widget',
      attributes: [
        {name: "activity_id", type: "string"},
        {name: "event_id", type: "string"},
        {name: "subject", type: "string"},
        {name: "tags", type: "string"},
        {name: "redirect_to", type: "reference"},
        {name: "submit_button_text", type: "string"},
      ]
    )
  end
end
