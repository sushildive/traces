require_relative "../helpers/traces_home_helper"
#require File.expand_path(File.dirname(__FILE__) + '../helpers/traces_home_helper')

class TracesHomeController < ApplicationController
  unloadable

  helper :issues
  include TracesHomeHelper::TracesModel
  include TracesHomeHelper
  include TracesHomeHelper::TracesEngine

  def index
    @question = params[:q] || ""
    @project = Project.find(params[:project_id])
    @offset = 0
    @limit = (TracesHomeHelper::APP_CFG[:limit.to_s]).to_i
    @data = nil
    @traces_data = nil
    #puts "(Traces)Search By text:#@question -- #@offset --limit:#@limit"
    @data = TracesEngine.loadData @project.id, @offset
    if !@data.nil? then
      @traces_data = @data.slice(0, @limit.to_i)
      if @data.size >  @limit.to_i
         @isNext = true
       end
    end
    render :index
  end

  def pages
   @question = params[:q] || ""
   @offset = (params[:offset]).to_i
   @isNext = false
   @data = nil
   @traces_data = nil
   @project = Project.find(params[:project_id])
   @limit = (TracesHomeHelper::APP_CFG[:limit.to_s]).to_i
   #puts "(Pages)Search By text:#@question -- offset:#@offset --limit:#@limit"
   @criteria = nil
   if(@question.match(/^%+$/))
      @criteria = "\\" + @question
   else
      @criteria = @question
   end

   if !@question.nil? && !@question.empty? then
      @data = TracesEngine.loadDataByCriteria @criteria, @project.id, @offset
   else
      @data = TracesEngine.loadData @project.id, @offset
   end

   if !@data.nil? then
     @traces_data = @data.slice(0, @limit.to_i)
     if @data.size >  @limit.to_i
        @isNext = true
      end
   end
   render :index
  end

  def searchstory
   @question = params[:q] || ""
   @criteria = nil
   if(@question.match(/^%+$/))
      @criteria = "\\" + @question
   else
      @criteria = @question
   end
   @offset = (params[:offset]).to_i
   @project = Project.find(params[:project_id])
   @limit = (TracesHomeHelper::APP_CFG[:limit.to_s]).to_i
   @data = nil
   @traces_data = nil
   @isNext = false
   #puts "(Criteria)Search By text:#@question -- offset:#@offset --limit:#@limit"

   # quick jump to an issue
   if (m = @question.match(/^#+(\d+)$/)) && (issue = Issue.visible.find_by_id(m[1].to_i))
      if issue.id == issue.root_id
        @data = TracesEngine.loadDataByIssueId issue
      end
   elsif !@question.nil? && !@question.empty? then
      @data = TracesEngine.loadDataByCriteria @criteria, @project.id, @offset
   else
      @data = TracesEngine.loadData @project.id, @offset
   end

   if !@data.nil? then
     @traces_data = @data.slice(0, @limit.to_i)
     if @data.size >  @limit.to_i
        @isNext = true
      end
   end
   render :index
  end

  def export
    @question = params[:q] || ""
    @project = Project.find(params[:project_id])
    @traces_data = nil
    @criteria = nil
    if(@question.match(/^%+$/))
       @criteria = "\\" + @question
    else
       @criteria = @question
    end

    if (m = @question.match(/^#+(\d+)$/)) && (issue = Issue.visible.find_by_id(m[1].to_i))
       if issue.id == issue.root_id
         @traces_data = TracesEngine.loadDataByIssueId issue
       end
    else
         @traces_data = TracesEngine.loadAllData @criteria, @project.id
    end
    respond_to do |format|
        format.xls
    end
  end
end
