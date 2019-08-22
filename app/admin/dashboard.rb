ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc {I18n.t("active_admin.dashboard")}

  content title: proc { "People currently inside" } do
    # Here is an example of a simple dashboard with columns and panels.

    columns do
      column do

        def show_panel(room_name, access_logs)
          panel "#{room_name}: #{access_logs.count}" do
            table_for access_logs do
              column('User') do |access_log|
                access_log.user ?
                link_to(access_log.user_id, admin_user_path(access_log.user)) :
                "N/A"
              end
              column('Employee Id') do |access_log|
                access_log.user_employee_id
              end
              column('Name') {|access_log| access_log.user_name}
              column('Entry') {|access_log| access_log.created_at}
              column('Entry method') {|access_log| status_tag access_log.access_method}
              column('Card number') {|access_log| access_log.card_number}
              column('Access Log Id') do |access_log|
                link_to access_log.id, admin_access_log_path(access_log)
              end
            end
          end
        end

        # Lock.all.each do |lock|
        #   users = AccessLog.latest_for_users_currently_behind(lock)
        #   show_panel lock.name, users
        # end

        Room.all.each do |room|
          users=AccessLog.latest_for_users_currently_behind(room)
          show_panel room.name, users
         end 


      end

      # column do
      #   panel "Info" do
      #     para "Welcome to ActiveAdmin."
      #   end
      # end
    end

    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end # content
end
