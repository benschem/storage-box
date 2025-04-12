class ItemsController < ApplicationController
  before_action :set_current_household, only: %i[index ]

  def index
    @items = current_household.items

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { item: @item }
    # end
  end

  def show
    @item = Item.find(params[:id])
  end
end
