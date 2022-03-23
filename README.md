# HTML Attributes Utilities

This is a small library intended to make it easier to deal with HTML
attributes. It was written to reduce overlap in the
[govuk-components](https://github.com/DFE-Digital/govuk-components) and
[govuk-formbuilder](https://github.com/DFE-Digital/govuk-formbuilder) libraries.

It provides refinements for `Hash` that allow:

* deep merging while protecting default values from being overwritten
* tidying hashes by removing key/value pairs that have empty or nil values

## Example use

```ruby
require "html_attributes_utils"

def MyPresenter
  using HTMLAttributesUtils

  def initialize(custom_attributes = {})
    @custom_attributes = custom_attributes
  end

  def attributes
    default_attributes
      .deep_merge_html_attributes(@custom_attributes)
      .deep_tidy_html_attributes
  end

private

  def default_attributes
    { lang: "en-GB", class: "govuk-juggling-widget" }
  end
end

MyPresenter.new(lang: "fr", class: "stripes", some_other_attr: "").attributes

=> { lang: "fr", class: ["govuk-juggling-widget", "stripes"] }
```
