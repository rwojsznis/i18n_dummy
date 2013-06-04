def reset_settings
  I18nDummy::Settings.class_variable_set :@@regex, nil
end
