class ApplicationsController < ApplicationController
  def index
    @applicants = Application.find(ApplicationPet.where(pet_id: params[:pet_id]).pluck(:application_id))
    @pet = Pet.find(params[:pet_id])
  end

  def new
    @fav_pet_objects = favorite.pet_objects
  end

  def create
    application = Application.new(application_params)

    pet_ids = params[:application][:pet_ids]

    if application.save
      pet_ids.each do |id|
        ApplicationPet.create(application_id: application.id, pet_id: id.to_i)
        favorite.toggle(id.to_i)
      end
      redirect_to "/favorites"
      flash[:notice] = "Your application has been submitted."
    else
      flash[:errors] = application.errors.full_messages
      redirect_to "/applications/new"
    end
  end

  def show
    @application = Application.find(params[:id])
  end

  def update
    application = Application.find(params[:id])
    pet = Pet.find(params[:pet_id])
    if application.can_approve(pet)
      application.approve_for(pet)
      redirect_to "/pets/#{pet.id}"
    elsif application.can_unapprove(pet)
      application.unapprove_for(pet)
      redirect_to "/applications/#{application.id}"
    end
  end

  private
  def application_params
    params.permit(:name, :address, :city, :state, :zip, :phone_number, :reason)
  end
end
