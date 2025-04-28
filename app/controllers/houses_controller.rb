class HousesController < ApplicationController
  before_action :set_house, only: %i[ edit update destroy ]

  def index
    @houses = policy_scope(House)
  end

  def create
    @house = House.new(house_params)
    authorize @house

    if @house.save
      @house.users << current_user
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "houses_list",
            partial: "houses/house",
            locals: { house: @house, new_room: Room.new, new_invite: Invite.new }
          )
        end
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    authorize @house
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "title_#{dom_id(@house)}",
          partial: "houses/form",
          locals: { house: @house }
        )
      end
    end
  end

  def update
    authorize @house
    if @house.update(house_params)
      redirect_to houses_path, notice: "House was successfully updated.", status: :see_other
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @house
    frame_id = dom_id(@house)
    @house.destroy!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(
          frame_id,
        )
      end
    end
  end

  private

  def set_house
    @house = House.find(params[:id])
  end

  def house_params
    params.require(:house).permit(:name)
  end
end
