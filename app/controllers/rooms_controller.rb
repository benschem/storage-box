class RoomsController < ApplicationController
  before_action :set_room, only: %i[ edit update destroy ]

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
            locals: { house: @house, new_room: Room.new, new_invite: Invite.new }
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
            locals: { house: @house, new_room: @room, new_invite: Invite.new }
          )
        end
      end
    end
  end

  def edit
    authorize @room
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@room),
          partial: "rooms/form",
          locals: { house: @room.house, room: @room }
        )
      end
    end
  end

  def update
    authorize @room
    @house = @room.house

    if @room.update(room_params)
      respond_to do |format|
        format.html { redirect_to houses_path, notice: "Room was successfully updated.", status: :see_other }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@house),
            partial: "houses/house",
            locals: { house: @house, new_room: Room.new, new_invite: Invite.new }
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
            locals: { house: @house, new_room: @room, new_invite: Invite.new }
          )
        end
      end
    end
  end

  def destroy
    authorize @room
    frame_id = dom_id(@room)
    @room.destroy!
    respond_to do |format|
      format.html { redirect_to "houses/index", notice: "Room was successfully destroyed.", status: :see_other }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(frame_id)
      end
    end
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :house_id)
  end
end
