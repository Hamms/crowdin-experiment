module ApplicationHelper
  def markdown(text)
    options = {
      filter_html: true,
    }

    extensions = {
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end
