require_relative "../helpers/traces_home_helper"
#require File.expand_path(File.dirname(__FILE__) + '../helpers/traces_home_helper')

class TracesHomeController < ApplicationController
  unloadable
  
  helper :issues
  include TracesHomeHelper::TracesModel
  include TracesHomeHelper
  include TracesHomeHelper::TracesEngine
  
  def index
    @project = Project.find(params[:project_id])
    @traces_data = TracesEngine.loadData @project.id
  end
end
