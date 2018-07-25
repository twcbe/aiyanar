class EmployeeAccessManager < AccessManager
  def initialize(employee_id, lock_name, direction)
    @employee_id = employee_id
    @direction = direction
    @lock = Lock.where({name: lock_name}).first
    @user = User.where({employee_id: employee_id}).first
  end

  def process
    access_allowed =  is_user_valid(@user) && @user.enabled && is_lock_valid(@lock) && has_permission(@lock, @user.roles)
    AccessLog.create!({
                          lock_id: @lock.try(:id),
                          access_method: 'face_recognition',
                          user_id: @user.try(:id),
                          direction: @direction,
                          access_provided: access_allowed}) unless @lock.try(:id).nil? || @user.try(:id).nil?
    access_allowed
  end
end
