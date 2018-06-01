ActiveAdmin.register Card do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
  permit_params :card_number, :user_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  form do |f|
    f.inputs do
      if card.card_number.nil?
        f.input :card_number
      else
        f.input :card_number, input_html: { disabled: true }
      end
      f.input :user
    end
    f.actions
  end

end
