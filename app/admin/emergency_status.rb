ActiveAdmin.register EmergencyStatus do
	config.clear_action_items!
	config.batch_actions = false
	actions :index
	index do
	  column :active
	  column :startTime
	  column :endTime
	end
end