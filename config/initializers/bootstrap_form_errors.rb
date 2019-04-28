# Override default field error functionality of Rails forms to use
# bootstrap-style validation classes instead of the default.
#
# Courtesy of https://jasoncharnes.com/bootstrap-4-rails-fields-with-errors/
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index + 7, 'is-invalid '
  else
    html_tag.insert html_tag.index('>'), ' class="is-invalid"'
  end
end
