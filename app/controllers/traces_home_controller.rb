class TracesHomeController < ApplicationController
  unloadable


  def index
    @project = Project.find(params[:project_id])
    @traces_data = []
  end
end
