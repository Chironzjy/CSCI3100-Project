class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy, :update_status]
  before_action :authorize_visibility!, only: [:show]
  before_action :authorize_owner!, only: [:edit, :update, :destroy, :update_status]

  def index
    @items = Item.with_attached_photos.includes(:user).available.visible_to(current_user).recent

    if params[:search].present?
      @items = @items.smart_search(params[:search])
    end

    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(college: params[:college])   if params[:college].present?
  end

  def show
  end

  def map
    @radius = params[:radius].to_i
    @radius = 5 if @radius <= 0
    @radius = 50 if @radius > 50

    base_scope = Item.includes(:user).available.visible_to(current_user).where.not(latitude: nil, longitude: nil)

    @items = if current_user.latitude.present? && current_user.longitude.present?
               base_scope.near([current_user.latitude, current_user.longitude], @radius, units: :km)
             else
               base_scope.recent.limit(100)
             end
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

  def authorize_visibility!
    return if @item.user == current_user
    return if @item.visibility_scope == "campus"
    return if @item.visibility_college.present? && @item.visibility_college == current_user.college

    redirect_to items_path, alert: "This listing is visible only to #{ @item.visibility_college || 'its college' }."
  end

  def item_params
    permitted = params.require(:item).permit(
      :title,
      :description,
      :price,
      :stock_quantity,
      :category,
      :college,
      :location,
      :latitude,
      :longitude,
      :visibility_scope,
      :visibility_college,
      photos: []
    )
    if permitted[:visibility_scope] == "college_only" && permitted[:visibility_college].blank?
      permitted[:visibility_college] = current_user.college
    end
    permitted
  end
end
