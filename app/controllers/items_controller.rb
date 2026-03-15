class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy, :update_status]
  before_action :authorize_owner!, only: [:edit, :update, :destroy, :update_status]

  def index
    @items = Item.includes(:user).available.recent

    if params[:search].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"
      @items = @items.where("title ILIKE ? OR description ILIKE ?", term, term)
    end

    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(college: params[:college])   if params[:college].present?
  end

  def show
  end

  def new
    @item = current_user.items.build
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to @item, notice: 'Item listed successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: 'Item updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: 'Listing removed.'
  end

  def update_status
    new_status = params[:status].to_s
    if Item::STATUSES.include?(new_status)
      @item.update!(status: new_status)
      redirect_to @item, notice: "Item marked as #{new_status}."
    else
      redirect_to @item, alert: 'Invalid status.'
    end
  end

  def my_items
    @items = current_user.items.recent
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def authorize_owner!
    redirect_to items_path, alert: 'Not authorized.' unless @item.user == current_user
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :category, :college)
  end
end
