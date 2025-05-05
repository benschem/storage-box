class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    items = policy_scope(Item).includes(:box, :room, image_attachment: :blob)

    house_id = safe_house_param
    items = items.where(house: house_id) if house_id

    room_id = safe_room_param
    items = items.joins(:room).where(rooms: { id: room_id }) if room_id

    if safe_box_param.present?
      case safe_box_param
      when :unboxed
        items = items.where(box_id: nil)
      when :boxed
        items = items.where.not(box_id: nil)
      else
        items = items.where(box_id: safe_box_param)
      end
    end

    if params[:search].present?
      items = items.search(params[:search])
    end

    @houses  = policy_scope(House).order(:name)
    @rooms = policy_scope(Room).order(:house_id).order(:name)
    @rooms_with_houses = policy_scope(Room).includes(:house).order(:house_id).order(:name)
    @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)

    order_by = safe_sort_param(params[:sort_by]) || :created_at
    direction = safe_direction_param(params[:sort_direction]) || :desc
    items = items.order(order_by => direction)

    @number_of_items = items.count
    @pagy, @items = pagy(items)
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
    authorize @item

    @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
    @rooms = policy_scope(Room).includes(:house).order(:house_id).order(:name)

    @tag = Tag.new
    @box = Box.new
  end

  def create
    @item = Item.new(item_params)
    @item.house = @item.room&.house
    @item.user = current_user
    authorize @item

    if @item.save
      respond_to do |format|
        format.html { redirect_to items_path, notice: "Item was successfully created." }
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
      @rooms = policy_scope(Room).includes(:house).order(:house_id).order(:name)

      @tag = Tag.new
      @box = Box.new

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
    @rooms = policy_scope(Room).includes(:house).order(:house_id).order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@item),
          partial: "items/edit",
          locals: { item: @item, boxes: @boxes, rooms: @rooms }
        )
      end
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
            partial: "items/edit",
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

  def item_params
    params.require(:item).permit(:name, :notes, :box_id, :room_id, :image, :remove_image, tag_ids: [])
  end

  def safe_house_param
    return nil unless params[:filter_by_house].present?

    house_id = params[:filter_by_house].to_i
    House.exists?(house_id) ? house_id : nil
  end

  def safe_room_param
    return nil unless params[:filter_by_room].present?

    room_id = params[:filter_by_room].to_i
    Room.exists?(room_id) ? room_id : nil
  end

  def safe_box_param
    return nil unless params[:filter_by_box].present?

    case params[:filter_by_box]
    when "unboxed"
      :unboxed
    when "boxed"
      :boxed
    else
      box_id = params[:filter_by_box].to_i
      Box.exists?(box_id) ? box_id : nil
    end
  end

  def safe_sort_param(param)
    allowed_sorts = %w[name created_at updated_at]
    allowed_sorts.include?(param) ? param.to_sym : nil
  end

  def safe_direction_param(param)
    allowed_directions = %w[asc desc]
    allowed_directions.include?(param) ? param.to_sym : nil
  end
end
