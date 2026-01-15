# frozen_string_literal: true

# Items controller
class ItemsController < ApplicationController
  before_action :set_items, only: %i[index]
  before_action :set_tags, only: %i[index]
  before_action :set_boxes, only: %i[index]
  before_action :set_rooms, only: %i[index]
  before_action :set_houses, only: %i[index]
  before_action :set_partial, only: [:show]

  before_action :set_item, only: %i[show edit update destroy]

  def index
    @pagy, @items = pagy(@items)
  end

  def show
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@item),
          partial: @partial,
          locals: { item: @item }
        )
      end
    end
  end

  def new
    @item = Item.new
    authorize @item

    @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
    @rooms = policy_scope(Room).includes(:house).order(:house_id, :name)

    @tag = Tag.new
    @box = Box.new
  end

  def edit
    @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
    @rooms = policy_scope(Room).includes(:house).order(:house_id, :name)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@item),
          partial: 'items/edit',
          locals: { item: @item, boxes: @boxes, rooms: @rooms }
        )
      end
    end
  end

  def create
    @item = Item.new(item_params)
    @item.house = @item.room&.house
    @item.user = current_user
    authorize @item

    if @item.save
      respond_to do |format|
        format.html { redirect_to items_path, notice: 'Item was successfully created.' }
        # format.turbo_stream do
        #   render turbo_stream: turbo_stream.append(
        #     "items_list",
        #     partial: "items/item",
        #     locals: { item: @item }
        #   )
        # end
      end
    else
      @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
      @rooms = policy_scope(Room).includes(:house).order(:house_id, :name)

      @tag = Tag.new
      @box = Box.new

      render :new, status: :unprocessable_content
    end
  end

  def update
    params.delete(:box_id) if params[:room_id] && @item.room.nil?
    params.delete(:room_id) if params[:box_id] && @item.box.nil?

    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.', status: :see_other }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@item),
            partial: 'items/item',
            locals: { item: @item }
          )
        end
      else
        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@item),
            partial: 'items/edit',
            locals: { item: @item }
          )
        end
      end
    end
  end

  def destroy
    frame_id = dom_id(@item)
    @item.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(frame_id) }
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
    authorize @item
  end

  def set_items
    all_items = policy_scope(Item)&.includes(:room, :box, image_attachment: :blob)
    @items = params[:search].present? ? all_items.search(params[:search]) : all_items
    @number_of_items = @items.count
  end

  def set_tags
    @tags = policy_scope(Tag)
  end

  def set_boxes
    @boxes = policy_scope(Box)
  end

  def set_rooms
    @rooms = policy_scope(Room).includes(:house)
  end

  def set_houses
    @houses = policy_scope(House)
  end

  def set_partial
    @partial = params[:closed] == 'true' ? 'items/item' : 'items/item_open'
  end

  def item_params
    params.expect(item: [:name, :notes, :box_id, :room_id, :image, :remove_image, { tag_ids: [] }])
  end
end
