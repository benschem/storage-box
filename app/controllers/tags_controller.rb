class TagsController < ApplicationController
  before_action :set_current_household, only: %i[show destroy]
  before_action :set_tag, only: %i[show destroy]

  def show
    params[:tab] = "boxes"
  end

  def destroy
    @tag.destroy
    redirect_to household_boxes_url(current_household), notice: 'Tag was successfully deleted.'
  end

  private

  def set_tag
    @tag = Tag.find_by(household: current_household, id: params[:id])
  end
end
