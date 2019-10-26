class EmergencyStatusHandler

  def initialize(mqtt_client)
    @mqtt_client = mqtt_client
  end

  def process(payload)
   Rails.logger.info "[mqtt_handler] EmergencyStatusHandler message; #{payload}"
   if "start_emergency".casecmp(payload['command'])==0
     emergencyStatus = EmergencyStatus.new(:active => true)
	 emergencyStatus.save
     Rails.logger.info "Data inserted for emergency status "
   	elsif "end_emergency".casecmp(payload['command'])==0
     result = EmergencyStatus.last
     result['active']=false
     result.save
   end
 end
end
