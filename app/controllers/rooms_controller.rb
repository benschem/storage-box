class RoomsController < ApplicationController
  before_action :set_room, only: %i[ update destroy ]

  def index
    @rooms = policy_scope(Room)
  end

  def create
    @room = Room.new(room_params)
    authorize @room
    @house = @room.house

    if @room.save
      respond_to do |format|
        format.html { redirect_to houses_path, notice: "Room was successfully created." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@house),
            partial: "houses/house",
            locals: { house: @house, new_room: Room.new }
          )
        end
      end
    else
      @houses = House.includes(:rooms).all
      respond_to do |format|
        format.html { render "houses/index", status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@house),
            partial: "houses/house",
            locals: { house: @house, new_room: @room }
          )
        end
      end
    end
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: "Room was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy!
    redirect_to roomes_url, notice: "Room was successfully destroyed.", status: :see_other
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :house_id)
  end
end
