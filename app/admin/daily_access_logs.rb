ActiveAdmin.register DailyAccessLog, as: "Daily Access Logs" do
  actions :index
  config.batch_actions = false
  filter :user
  filter :lock
  filter :date, as: :date_range

  index do
    column('Date', sortable: "date") {|access_log| access_log.date}
    column('User', sortable: "user_id") do |access_log|
      access_log.user ?
      link_to(access_log.user_name, admin_user_path(access_log.user)) :
      ""
    end
    column('Employee Id', sortable: false) do |access_log|
      access_log.user_employee_id
    end
    column('Card number', sortable: "card_number") {|access_log| access_log.card_number}
    column('First Entry', sortable: "fisrt_enter") {|access_log| access_log.first_enter}
    column('Last Exit', sortable: "last_exit") {|access_log| access_log.last_exit}
  end

  csv do
    column('Date') {|access_log| access_log.date}
    column('Employee Id') do |access_log|
      access_log.user_employee_id
    end
    column('Name') {|access_log| access_log.user_name}
    column('Card number') {|access_log| access_log.card_number}
    column('First Entry') {|access_log| access_log.first_enter.try :strftime, "%I:%M %P"}
    column('Last Exit') {|access_log| access_log.last_exit.try :strftime, "%I:%M %P" }
  end
end
