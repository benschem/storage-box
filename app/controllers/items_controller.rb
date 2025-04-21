class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    if params[:search].present?
      @items = Item.search(params[:search])
    else
      @items = Item.all.order(:name)
    end
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream do
        partial = params[:closed] == "true" ? "items/item" : "items/item_open"
        render turbo_stream: turbo_stream.replace(
          dom_id(@item),
          partial: partial,
          locals: { item: @item }
        )
      end
    end
  end

  def new
    @item = Item.new
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@item),
          partial: "items/form",
          locals: { item: @item }
        )
      end
    end
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      respond_to do |format|
        format.html { redirect_to @item, notice: "Item was successfully created." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "items_list",
            partial: "items/item",
            locals: { item: @item }
          )
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:room_id] && (@item.room == nil)
      params.delete(:box_id)
    end

    if params[:box_id] && (@item.box == nil)
      params.delete(:room_id)
    end

    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: "Item was successfully updated.", status: :see_other }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@item),
            partial: "items/item",
            locals: { item: @item }
          )
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@item),
            partial: "items/form",
            locals: { item: @item }
          )
        end
      end
    end
  end

  def destroy
    @item.destroy!

    respond_to do |format|
      format.html { redirect_to items_url, notice: "Item was successfully destroyed.", status: :see_other }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@item)) }
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :notes, :box_id, :room_id, :image)
  end
end
