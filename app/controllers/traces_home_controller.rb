class TracesHomeController < ApplicationController
  unloadable
  
  helper :issues

  def index
    @project = Project.find(params[:project_id])
    @traces_data = []
  end
end
