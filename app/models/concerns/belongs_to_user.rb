module BelongsToUser
  def user_id
    user.try :id
  end

  def user_name
    user.try :name
  end

  def user_employee_id
    user.try :employee_id
  end
end
