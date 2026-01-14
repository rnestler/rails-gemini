class GeminiController < ApplicationController
  def index
    render formats: [:gmi], content_type: 'text/gemini'
  end

  def about
    render formats: [:gmi], content_type: 'text/gemini'
  end
end
