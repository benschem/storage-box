class TagsController < ApplicationController
  before_action :set_current_house, only: %i[show destroy]
  before_action :set_tag, only: %i[show destroy]

  def show
    params[:tab] = "boxes"
  end

  def destroy
    @tag.destroy
    redirect_to house_boxes_url(current_house), notice: 'Tag was successfully deleted.'
  end

  private

  def set_tag
    @tag = Tag.find_by(house: current_house, id: params[:id])
  end
end
