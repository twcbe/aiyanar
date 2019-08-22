ActiveAdmin.register Lock do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
  permit_params :name, :room_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  show title: :name do

    panel "Recent Accesses" do
      access_logs_for_lock = AccessLog.recent_logs_for_lock(lock, 5)
      if access_logs_for_lock.empty?
        b "No recent accesses logged"
        next
      end
      table_for(access_logs_for_lock) do
        column('Card') do |access_log|
          access_log.card_number
        end
        column('User') do |access_log|
          link_to access_log.user.name, admin_user_path(access_log.user) unless access_log.user.nil?
        end
        column('Direction') do |access_log|
          access_log.direction
        end
        column('Access Provided') do |access_log|
          access_log.access_provided
        end
        column('Created at') do |access_log|
          access_log.created_at
        end
        tr do
          td do
            link_to "View all", admin_access_logs_path(commit: 'Filter', order: 'created_at_desc', "q[lock_id_eq]": lock.id)
          end
        end
      end
    end

    attributes_table(*default_attribute_table_rows)
  end

  form do |f|
    f.inputs do
     f.input :name
     f.input :room

    end
    f.actions
  end

end
