ActiveAdmin.register DailyAccessLog, as: "Daily Access Logs" do
  actions :index
  config.batch_actions = false
  filter :user
  filter :room
  filter :date, as: :date_range

  index do
    column('Date', sortable: "date") { | daily_access_log | daily_access_log.date }
    column('User', sortable: "user_id") do |daily_access_log|
      daily_access_log.user ?
      link_to(daily_access_log.user_name, admin_user_path(daily_access_log.user)) :
      ""
    end
    column('Employee Id', sortable: false) do |daily_access_log|
      daily_access_log.user_employee_id
    end
    column('Room', sortable: "room_id") do |daily_access_log|
      daily_access_log.room.name
    end
    column('Card number', sortable: "card_number") {|daily_access_log| daily_access_log.card_number}
    column('First Entry', sortable: "fisrt_enter") {|daily_access_log| daily_access_log.first_enter}
    column('Last Exit', sortable: "last_exit") {|daily_access_log| daily_access_log.last_exit}
  end

  csv do
    column('Date') {|daily_access_log| daily_access_log.date}
    column('Employee Id') do |daily_access_log|
      daily_access_log.user_employee_id
    end
    column('Name') {|daily_access_log| daily_access_log.user_name}
    column('Card number') {|daily_access_log| daily_access_log.card_number}
    column('First Entry') {|daily_access_log| daily_access_log.first_enter.try :strftime, "%I:%M %P"}
    column('Last Exit') {|daily_access_log| daily_access_log.last_exit.try :strftime, "%I:%M %P" }
  end
end
