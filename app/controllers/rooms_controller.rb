class RoomsController < ApplicationController
  def index
    @household = Household.find(params[:household_id])
    @rooms = @household.rooms
    params[:tab] = "rooms"

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { room: @room }
    # end
  end
end
