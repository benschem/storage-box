class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show update destroy ]

  def index
    if params[:search].present?
      @items = Item.search(params[:search])
    else
      @items = Item.all
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render partial: "items/list", locals: { items: @items }
      end
    end
  end

  def show
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item, notice: "Item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    redirect_to items_url, notice: "Item was successfully destroyed.", status: :see_other
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name)
  end
end
