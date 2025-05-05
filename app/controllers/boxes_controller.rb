class BoxesController < ApplicationController
  before_action :set_box, only: %i[ show update destroy ]

  def index
    @boxes = policy_scope(Box)
  end

  def show
  end

  def create
    @box = Box.new(box_params)
    authorize @box

    if @box.save
      redirect_to new_item_path, notice: "Box was successfully created."
    else
      render "items/new", status: :unprocessable_entity
    end
  end

  def update
    if @box.update(box_params)
      redirect_to @box, notice: "Box was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @box.destroy!
    redirect_to boxes_url, notice: "Box was successfully destroyed.", status: :see_other
  end

  private

  def set_box
    @box = Box.find(params[:id])
  end

  def box_params
    params.require(:box).permit(:room_id)
  end
end
