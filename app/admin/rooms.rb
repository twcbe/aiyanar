ActiveAdmin.register Room do
    permit_params :name,lock_ids: []

    form do |f|
    f.inputs do
      f.input :name
      f.input :locks
    end
    f.actions
  end

end	