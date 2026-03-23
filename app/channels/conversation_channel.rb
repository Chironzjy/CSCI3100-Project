class ConversationChannel < ApplicationCable::Channel
  def subscribed
    @conversation = Conversation.find(params[:conversation_id])

    reject unless @conversation.participant?(current_user)

    stream_for @conversation
  end
end
