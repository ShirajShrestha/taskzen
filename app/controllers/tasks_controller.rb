class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]
  include ActionView::RecordIdentifier

  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def show
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("task_show", partial: "tasks/show", locals: { task: @task })
      end
      format.html # Fallback for non-Turbo requests
    end
  end

  def new
    @task = current_user.tasks.new
    respond_to do |format|
      format.html # for non-Turbo requests
      format.turbo_stream # for Turbo requests
    end
  end

  def create
    @task = current_user.tasks.new(task_params)

    if @task.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.prepend(
            "#{@task.status.parameterize.underscore}_tasks",
            partial: "tasks/card",
            locals: { task: @task }
          ),
          turbo_stream.remove("task_form")
        ]
        end
        format.html { redirect_to tasks_path, notice: "Task created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("task_form", partial: "form", locals: { task: @task }), status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("task_#{@task.id}"),
            turbo_stream.prepend(
              "#{@task.status.downcase}_tasks",
              parital: "tasks/card",
              locals: { task: @task }
            )
          ]
        end
        format.html { redirect_to tasks_path, notice: "Task updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_frame", partial: "form", locals: { task: @task }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # @task.destroy
    # respond_to do |format|
    #   format.turbo_stream do
    #     render turbo_stream: [
    #       turbo_stream.remove("task_#{@task.id}"),
    #       turbo_stream.remove("task_show")
    #     ]
    #   end
    #   format.html { redirect_to tasks_path, notice: "Task deleted successfully." }
    # end

    @task.destroy
    if @task
      respond_to do |format|
        format.turbo_stream do
          streams = [
            turbo_stream.remove("task_#{@task.id}"),
            turbo_stream.remove("task_show")
          ]

          if dom_id(@task) == "task_show"
            streams << turbo_stream.remove("task_show")
          end

          render turbo_stream: streams
        end
        format.html { redirect_to tasks_path, notice: "Task deleted successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("task_show")
        end
        format.html { redirect_to tasks_path, alert: "Task not found or already deleted." }
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
