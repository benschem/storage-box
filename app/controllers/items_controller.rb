class ItemsController < ApplicationController
  before_action :set_current_house, only: %i[index ]

  def index
    @items = current_user.items

    # if turbo_frame_request? && params[:tab]
    #   render partial: "#{params[:tab]}_tab", locals: { item: @item }
    # end
  end
end
