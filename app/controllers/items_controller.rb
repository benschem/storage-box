class ItemsController < ApplicationController
  def index
    @household = Household.find(params[:household_id])
    @items = @household.items
    params[:tab] = "items"

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { item: @item }
    # end
  end
end
