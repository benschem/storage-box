class HousesController < ApplicationController
  before_action :set_house, only: %i[ update destroy ]

  def index
    @houses = current_user.houses
  end

  def create
    @house = House.new(house_params)

    if @house.save
      redirect_to @house, notice: "House was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @house.update(house_params)
      redirect_to @house, notice: "House was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @house.destroy!
    redirect_to housees_url, notice: "House was successfully destroyed.", status: :see_other
  end

  private

  def set_house
    @house = House.find(params[:id])
  end

  def house_params
    params.require(:house).permit(:name)
  end
end
