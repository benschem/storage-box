# frozen_string_literal: true

# Use user submitted params to filter items
module ItemFilter
  extend ActiveSupport::Concern

  included do
    def apply_filters
      apply_house_filter if params[:filter_by_house].present?
      apply_room_filter if params[:filter_by_room].present?
      apply_box_filter if params[:filter_by_box].present?
      apply_tag_filter if params[:filter_by_tag].present?
    end

    def load_filter_options
      @houses = policy_scope(House).order(:name)
      @rooms = policy_scope(Room).order(:house_id, :name)
      @rooms_with_houses = policy_scope(Room).includes(:house).order(:house_id, :name)
      @boxes = policy_scope(Box).includes(room: :house).order(:house_id).order(:number)
      @tags = policy_scope(Tag).order(:name)
    end
  end

  private

  def apply_house_filter
    house = House.find(params[:filter_by_house].to_i)
    @items = @items.where(house:) if house
  end

  def apply_room_filter
    room = Room.find(params[:filter_by_room].to_i)
    @items = @items.joins(:room).where(rooms: { id: room }) if room
  end

  def apply_box_filter
    @items =  case params[:filter_by_box]
              when 'unboxed'
                @items.where(box_id: nil)
              when 'boxed'
                @items.where.not(box_id: nil)
              else
                @items.where(box_id: Box.find(id: params[:filter_by_box].to_i))
              end
  end

  def apply_tag_filter
    tag = Tag.find(id: params[:filter_by_tag].to_i)
    return unless tag

    @items = @items
             .joins(:tags)
             .where(tags: { id: tag })
             .distinct
  end
end
