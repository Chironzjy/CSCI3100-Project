class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_participant!

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_path(@conversation), notice: "Message sent."
    else
      redirect_to conversation_path(@conversation), alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def authorize_participant!
    return if @conversation.participant?(current_user)

    redirect_to conversations_path, alert: "Not authorized."
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
