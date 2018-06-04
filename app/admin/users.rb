ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
  permit_params :employee_id, :name, card_ids: [], role_ids: []
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  show title: :name do

    panel "Issued Cards" do
      table_for(user.cards) do
        column("Cards") do |card|
          link_to "#{card.card_number}", admin_card_path(card)
        end
      end unless user.cards.empty?
      b "No cards issued" if user.cards.empty?
    end

    panel "Assigned Roles" do
      table_for(user.roles) do
        column("Roles") do |role|
          link_to "#{role.name}", admin_role_path(role)
        end
      end unless user.roles.empty?
      b "No roles assigned" if user.roles.empty?
    end

    attributes_table(*default_attribute_table_rows)
  end

  form do |f|
    f.inputs "Details" do
      if user.new_record?
        f.input :employee_id, label: "Employee Id"
      else
        f.input :employee_id, label: "Employee Id", input_html: { disabled: true }
      end
      f.input :name
      f.input :cards
      f.input :roles
    end
    f.actions
  end

end
