# frozen_string_literal: true

# Use user submitted params to sort items
module ItemSort
  extend ActiveSupport::Concern

  ALLOWED_SORTS = %w[name created_at updated_at].freeze
  ALLOWED_DIRECTIONS = %w[asc desc].freeze

  included do
    def apply_sort
      order_by = ALLOWED_SORTS.include?(params[:sort_by]) ? params[:sort_by].to_sym : :created_at
      direction = ALLOWED_DIRECTIONS.include?(params[:sort_direction]) ? params[:sort_direction].to_sym : :desc

      @items = @items.order(order_by => direction)
    end
  end
end
