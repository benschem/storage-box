class BoxesController < ApplicationController
  def index
    @boxes = current_user.boxes

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { boxes: @boxes }
    # end
  end
end
