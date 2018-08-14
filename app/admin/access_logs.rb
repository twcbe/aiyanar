ActiveAdmin.register AccessLog do
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

  # includes :user, :card, :lock
  actions :index, :show
  config.batch_actions = false

  index do
    column("Id", :sortable => :id) {|access_log| link_to "#{access_log.id}", admin_access_log_path(access_log)}
    column("Lock", :sortable => :lock_id) {|access_log| link_to "#{access_log.lock.name}", admin_lock_path(access_log.lock)}
    column("Card Number", :sortable => :card_number) {|access_log| "#{access_log.card_number}"}
    column("User", :sortable => :user_id) {|access_log| link_to "#{access_log.user.name}", admin_user_path(access_log.user)}
    column("Direction", :sortable => :direction) do |access_log|
      a href: admin_access_logs_path(:commit => 'Filter', 'q[direction_equals]' => access_log.direction) do
        status_tag("#{access_log.direction}")
      end
    end
    column("Access Provided", :sortable => :access_provided) do |access_log|
      a href: admin_access_logs_path(:commit => 'Filter', 'q[access_provided_eq]' => access_log.access_provided) do
        status_tag("#{access_log.access_provided}")
      end
    end
    column("Created At", :sortable => :created_at, &:created_at)
    column("Updated At", :sortable => :updated_at, &:updated_at)
    column("Access Method", :sortable => :access_method) do |access_log|
      a href: admin_access_logs_path(:commit => 'Filter', 'q[access_method_equals]' => access_log.access_method) do
        status_tag("#{access_log.access_method}")
      end
    end

    # column("Order", :sortable => :id) {|order| link_to "##{order.id} ", admin_order_path(order) }
    # column("State")                   {|order| status_tag(order.state) }
    # column("Date", :checked_out_at)
    # column("Customer", :user, :sortable => :user_id)
    # column("Total")                   {|order| number_to_currency order.total_price }
  end
end
