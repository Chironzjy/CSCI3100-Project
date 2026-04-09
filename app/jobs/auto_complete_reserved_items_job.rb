class AutoCompleteReservedItemsJob < ApplicationJob
  queue_as :default

  def perform
    Item.auto_complete_reserved!
  end
end
