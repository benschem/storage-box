class RoomsController < ApplicationController
  before_action :set_current_household, only: %i[ index show ]

  def index
    @rooms = current_household.rooms

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { room: @room }
    # end
  end

  def show
    @room = Room.find(params[:id])
  end
end
