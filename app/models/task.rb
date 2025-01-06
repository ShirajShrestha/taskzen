class Task < ApplicationRecord
  include ActionView::RecordIdentifier
  belongs_to :user
  validates :title, presence: true
  validates :priority, inclusion: { in: %w[Low Medium High], message: "%{value} is not a valid priority" }, allow_nil: true
  validates :status, presence: true
  validates :due_date, presence: true

  after_create_commit -> { broadcast_task_to_status }
  after_update_commit -> { broadcast_task_update_to_status }
  after_destroy_commit -> { broadcast_task_removal_from_status }

  private

  # Broadcast task to its respective status list when created
  def broadcast_task_to_status
    broadcast_prepend_to(
      "#{status.parameterize.underscore}_tasks",
      target: "#{status.parameterize.underscore}_tasks",
      partial: "tasks/task",
      locals: { task: self }
      )
  end

  # Broadcast task update to its respective status list when updated
  def broadcast_task_update_to_status
    # broadcast_replace_to(
    #   "#{status.parameterize.underscore}_tasks",
    #   target: dom_id(self),
    #   partial: "tasks/task",
    #   locals: { task: self }
    # )

    if saved_change_to_status?
      # Remove from the old status list
      old_status = status_before_last_save
      broadcast_remove_to(
        "#{old_status.parameterize.underscore}_tasks",
        target: dom_id(self)
      )

      # Add to the new status list
      broadcast_task_to_status
    else
      # If status hasn't changed, just update within the same list
      broadcast_replace_to(
        "#{status.parameterize.underscore}_tasks",
        target: dom_id(self),
        partial: "tasks/task",
        locals: { task: self }
      )
    end
  end

  # Broadcast task removal from its respective status list when deleted
  def broadcast_task_removal_from_status
    broadcast_remove_to(
      "#{status.parameterize.underscore}_tasks",
      target: dom_id(self)
    )
  end
end
