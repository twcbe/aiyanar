ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
  permit_params :employee_id, :name
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
        column("Card") do |card|
          link_to "#{card.card_number}", admin_card_path(card)
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :employee_id, input_html: { disabled: true }
      f.input :name
    end
    f.actions
  end

end
