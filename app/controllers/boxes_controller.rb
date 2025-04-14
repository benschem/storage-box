class BoxesController < ApplicationController
  before_action :set_current_house, only: %i[ index show ]

  def index
    @boxes = current_house.boxes

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { boxes: @boxes }
    # end
  end

  def show
    @box = Box.find(params[:id])
  end
end
