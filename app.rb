require 'rubygems'
require 'sinatra'
require 'slim'
require 'yaml'
require 'pathname'
require 'fileutils'
require 'set'
require './i18n_dummy/common'
require './i18n_dummy/locale'
require './i18n_dummy/config'
require './i18n_dummy/error'
require './i18n_dummy/settings'
require './i18n_dummy/parser/base'
require './i18n_dummy/parser/node'
require './i18n_dummy/parser/node_value'
require './i18n_dummy/parser/diff'
require './i18n_dummy/extensions/string'
require './helpers/application'


class I18nDummyApp < Sinatra::Base
  helpers ApplicationHelper

  before do
    begin
      @locales = I18nDummy::Config.load

      rescue I18nDummy::Error => e
        @exception = e
        halt slim(:error)
    end
  end

  get '/' do
    slim :index
  end

  get '/about' do
    slim :about
  end

  get '/locale/:locale/?:done?' do
    @locale = @locales.fetch(params[:locale])
    @flash  = params[:done]
    @translations, @diff = {}, {}

    @locale.each do |key, value|
      parser = I18nDummy::Parser::Base.new(value)
      @translations[key.to_sym] = parser
      @diff[key.to_sym] = I18nDummy::Parser::Diff.new(@translations[:base], parser) unless key == "base"
    end

    slim :locale
  end

  post '/parse' do
    locale  = @locales.fetch(params[:locale])
    backup  = params[:backup]
    parsers = {}
    parsers[:base] = I18nDummy::Parser::Base.new(locale['base'])

    # prepare dummy parser for each locale
    locale.each do |key, value|
      next if key == "base"

      local_parser = I18nDummy::Parser::Base.new(value)
      parsers[key.to_sym] = I18nDummy::Locale.prepare!(parsers[:base], local_parser)
    end

    # this will validate each output using Psych.load
    # let it explode for now if this happens
    # and do not save any changes (safe approach)
    parsers.each do |key, value|
       value.validate!
    end

    parsers.each do |key, value|
      value.save!(backup)
    end

    redirect to("/locale/#{params[:locale]}/done")
  end

end
