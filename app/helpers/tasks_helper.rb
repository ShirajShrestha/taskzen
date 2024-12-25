module TasksHelper
  def priority_color_class(task)
    case task.priority
    when "Low"
      "bg-green-100 text-green=600"
    when "Medium"
      "bg-orange-100 text-orange-600"
    when "High"
      "bg-red-100 text-red-600"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
