class TagsController < ApplicationController
  before_action :set_tag, only: %i[ update destroy remove ]
  before_action :set_item, only: %i[ remove ]

  def index
    @tags = policy_scope(Tag)
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    @tag.user = current_user
    authorize @tag

    if @tag.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "tags_list",
            partial: "tags/tag",
            locals: { tag: @tag }
          )
        end
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    authorize @tag

    if @tag.update(tag_params)
      redirect_to @tag, notice: "Tag was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tag
    @tag.destroy

    redirect_to tags_path, notice: "Tag deleted"
  end

  def remove
    authorize @tag
    @item.tags.delete(@tag)

    respond_to do |format|
      format.html { redirect_to items_path, notice: "Tag successfully removed from #{@item.name}." }
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

  private

  def set_item

    @item = Item.find(params[:item_id])
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
