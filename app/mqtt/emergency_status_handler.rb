require 'time'
class EmergencyStatusHandler

  def initialize(mqtt_client)
    @mqtt_client = mqtt_client
  end

  def process(payload)
   Rails.logger.info "[mqtt_handler] EmergencyStatusHandler message; #{payload}"
   if "start_emergency".casecmp(payload['command'])==0
    startTime = Time.now.utc.iso8601
    emergencyStatus = EmergencyStatus.new(:active => true,:startTime=>startTime)
	  emergencyStatus.save
     Rails.logger.info "Data inserted for emergency status "
   	elsif "end_emergency".casecmp(payload['command'])==0
     result = EmergencyStatus.last
     endTime = Time.now.utc.iso8601
     result['active']=false
     result['endTime']=endTime
     result.save
   end
 end
end
