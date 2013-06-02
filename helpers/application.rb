require 'sinatra/base'

module ApplicationHelper
  def locale_link(key)
    (params[:locale] == key) ? key : "<a href='/locale/#{key}'>#{key}</a>"
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end