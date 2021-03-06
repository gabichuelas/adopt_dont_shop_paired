class PetsController < ApplicationController

  def index
    @pets = Pet.all
  end

  def show
    @pet = Pet.find(params[:id])
    @fav_pet_objects = favorite.pets
    @applicants = Application.find(ApplicationPet.where(pet_id: @pet.id).pluck(:application_id))
  end

  def new
    @shelter = Shelter.find(params[:shelter_id])
  end

  def create
    shelter = Shelter.find(params[:shelter_id])
    new_pet = shelter.pets.new(pet_params)
    if new_pet.save
      redirect_to "/shelters/#{shelter.id}/pets"
    else
      flash[:errors] = new_pet.errors.full_messages
      redirect_to "/shelters/#{shelter.id}/pets/new"
    end
  end

  def edit
    @pet = Pet.find(params[:id])
  end

  def update
    @pet = Pet.find(params[:id])
    @pet.update(pet_params)
    if @pet.valid?
      redirect_to "/pets/#{@pet.id}"
    else
      flash[:errors] = @pet.errors.full_messages
      redirect_to "/pets/#{@pet.id}/edit"
    end
  end

  def destroy
    pet = Pet.find(params[:id])
    if pet.status == :pending
      flash[:notice] = "Cannot delete a pet with pending application."
      redirect_back(fallback_location:"/pets")
    else
      favorite.pets.delete(pet.id.to_i)
      Pet.destroy(pet.id)
      redirect_to "/pets"
    end
  end

  private
  def pet_params
    params.permit(:name, :approx_age, :description, :sex, :image)
  end

end
