class FaceHandler
  SERVER_TOPIC = 'access_control/server'

  def initialize(mqtt_client)
    @mqtt_client = mqtt_client
  end

  def process(message)
    return if message['employee_id'].blank? || message['source'].blank?
    lock_name, direction = message['source'].split(':')
    return if lock_name.blank? || direction.blank?
    is_access_allowed = EmployeeAccessManager.new(message['employee_id'], lock_name, direction).process
    if is_access_allowed
      Rails.logger.info "[face_handler] Provided access to employee id #{message['employee_id']} at #{lock_name}"
      payload = {command: 'open_door', duration: 5, beeps: 1, lock_name: lock_name}.to_json
    else
      Rails.logger.info "[face_handler] Denied access to employee id #{message['employee_id']}"
      payload = {command: 'deny_access', beeps: 2, feedback_led: 'toggle_twice'}.to_json
    end
    Rails.logger.info "[face_handler] sending message: #{payload}"
    @mqtt_client.publish(SERVER_TOPIC, payload)
  end
end
