class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @task = current_user.tasks.new
  end

  def create
    @task = current_user.tasks.new(task_params)

    if @task.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created successfully" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.turbo_stream
        format.html { redirect_to task_path(@task), notice: "Task updated successfully" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
      respond_to do |format|
        if @task.destroy
          format.turbo_stream
          format.html { redirect_to tasks_path, notice: "Task deleted successfully." }
        else
          format.html { redirect_to tasks_path, alert: "Task could not be deleted." }
        end
      end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date)
  end
end
