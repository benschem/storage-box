class HouseholdsController < ApplicationController
  before_action :set_household, only: %i[ show update destroy ]
  before_action :set_current_household, only: %i[ show index ]

  def show
  end

  def index
    @households = current_user.households
  end

  def create
    @household = Household.new(household_params)

    if @household.save
      redirect_to @household, notice: "Household was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @household.update(household_params)
      redirect_to @household, notice: "Household was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @household.destroy!
    redirect_to householdes_url, notice: "Household was successfully destroyed.", status: :see_other
  end

  private

  def set_household
    @household = Household.find(params[:id])
  end

  def household_params
    params.require(:household).permit(:name)
  end
end
