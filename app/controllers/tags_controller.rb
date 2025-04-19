class TagsController < ApplicationController
  before_action :set_tag, only: %i[ update destroy ]
  before_action :set_tag, only: %i[ destroy ]

  def index
    @tags = current_user.tags
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to @tag, notice: "Tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: "Tag was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item = @tag.item
    @tag.destroy!

    respond_to do |format|
      format.html do
        redirect_to items_url, notice: "Tag successfully removed from #{@item.name}.", status: :see_other
      end
      format.turbo_stream do
        render "/items/_list", locals: { item: @item }
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
