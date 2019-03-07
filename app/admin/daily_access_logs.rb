ActiveAdmin.register AccessLog, as: "Daily Access Logs" do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  Lock.all.each do |lock|
    scope lock.name.to_sym, default: true do |access_log|
      access_log = access_log.fist_in_last_out_entries_per_day(lock)
    end
  end

  controller do
    def scoped_collection
      AccessLog.fist_in_last_out_entries_per_day(Lock.all.first)
    end
  end

  # includes :user, :card, :lock
  actions :index
  config.batch_actions = false
  # filter :created_at

  index do
    column('Date') {|access_log| access_log.date}
    column('User') do |access_log|
      link_to "#{access_log.user.name}", admin_user_path(access_log.user)
    end
    column('Employee Id') do |access_log|
      "#{access_log.user.employee_id}"
    end
    column('Card number') {|access_log| access_log.card_number}
    column('First Entry') {|access_log| access_log.first_enter}
    column('Last Exit') {|access_log| access_log.last_exit}
  end

  csv do
    column('Date') {|access_log| access_log.date}
    column('Employee Id') do |access_log|
      "#{access_log.user.employee_id}"
    end
    column('Name') {|access_log| access_log.user.name}
    column('Card number') {|access_log| access_log.card_number}
    column('First Entry') {|access_log| access_log.first_enter}
    column('Last Exit') {|access_log| access_log.last_exit}
  end
end
