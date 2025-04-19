class RoomsController < ApplicationController
  before_action :set_room, only: %i[ update destroy ]

  def index
    @rooms = current_user.rooms

    render partial: "rooms/list", locals: { rooms: @rooms }
  end

  def new
    @room = Room.new

    render partial: "rooms/form", locals: { room: @room }
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      respond_to do |format|
        format.html { redirect_to @room, notice: "Room was successfully created." }
        format.turbo_stream do
          render partial: "rooms/room", locals: { room: @room }
        end
      end
    else
      render partial: "rooms/form", status: :unprocessable_entity
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
    params.require(:room).permit(:name)
  end
end
