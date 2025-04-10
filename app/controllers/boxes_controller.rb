class BoxesController < ApplicationController
  def index
    @household = Household.find(params[:household_id])
    @boxes = @household.boxes
    params[:tab] = "boxes"

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { boxes: @boxes }
    # end
  end
end
