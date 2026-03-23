class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]
  before_action :authorize_participant!, only: [:show]

  def index
    @conversations = current_user.conversations.includes(:item, :buyer, :seller, messages: :user)
                                 .order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.includes(:user)
    @counterpart = @conversation.counterpart_for(current_user)
  end

  def create
    item = Item.find(params[:item_id])

    unless Item.visible_to(current_user).where(id: item.id).exists?
      redirect_to items_path, alert: "You cannot message this seller for a restricted listing."
      return
    end

    if item.user == current_user
      redirect_to item_path(item), alert: "You cannot start a chat with yourself."
      return
    end

    buyer = current_user
    seller = item.user

    @conversation = Conversation.find_or_create_by!(item: item, buyer: buyer, seller: seller)
    redirect_to conversation_path(@conversation)
  end

  private

  def set_conversation
    @conversation = Conversation.includes(:item, :buyer, :seller).find(params[:id])
  end

  def authorize_participant!
    return if @conversation.participant?(current_user)

    redirect_to conversations_path, alert: "Not authorized to view this conversation."
  end
end
