Redmine::Plugin.register :traces do
  name 'Traces RTM plugin'
  author 'Need'
  description 'This is a plugin for Redmine.  Mines and renders RTM.  Primitive.  Evolving.'
  version '0.0.1'
  url 'http://home.for.homeless.now/traces'
  author_url 'http://home.for.homeless.now/about/Need'
  menu :project_menu, :traces_menu, {:controller => 'traces_home', :action => 'index'}, :caption=>:text_menu_home, :param => :project_id, :after=>:activity
  permission :traces_menu, {:traces_home=>[:index]}, :public=>true
end
