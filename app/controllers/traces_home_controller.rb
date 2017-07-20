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
    @offset = 0
    @limit = TracesHomeHelper::APP_CFG[:limit.to_s]
    @data = TracesEngine.loadData @project.id, @offset
    @traces_data = @data.slice(0, @limit.to_i)
    @isNext = false
    if @data.size >  @limit.to_i
        @isNext = true
    end
  end

  def pages
   @offset = params[:offset]
   @project = Project.find(params[:project_id])
   @limit = TracesHomeHelper::APP_CFG[:limit.to_s]
   @data = TracesEngine.loadData @project.id, @offset
   @traces_data = @data.slice(0, @limit.to_i)
   @isNext = false
   if @data.size >  @limit.to_i
       @isNext = true
   end
  end
end
