require "rails_helper"

RSpec.describe StaleAlertJob, type: :job do
  let!(:system_user) do
    User.create!(
      email: "system@local",
      password: "password123",
      user_name: "System",
      location: "CUHK",
      latitude: 22.4133,
      longitude: 114.2104,
      college: "Shaw College"
    )
  end

  let!(:seller) do
    User.create!(
      email: "rspec_stale_seller@cuhk.local",
      password: "password123",
      user_name: "RSpec Stale Seller",
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093,
      college: "United College"
    )
  end

  it "sends reminder for inactive item over 15 days" do
    item = Item.create!(
      user: seller,
      title: "RSpec Inactive Reminder Item",
      description: "Inactive item for reminder",
      price: 200,
      category: "Books",
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093,
      stock_quantity: 1,
      status: "inactive",
      visibility_scope: "campus"
    )
    item.update_columns(updated_at: 20.days.ago)

    expect { described_class.perform_now }.to change(Message, :count).by(1)
    expect(Message.last.body).to include("inactive for over 15 days")
  end

  it "deletes inactive item over 30 days" do
    item = Item.create!(
      user: seller,
      title: "RSpec Inactive Cleanup Item",
      description: "Inactive item for cleanup",
      price: 260,
      category: "Others",
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093,
      stock_quantity: 1,
      status: "inactive",
      visibility_scope: "campus"
    )
    item.update_columns(updated_at: 40.days.ago)

    expect { described_class.perform_now }.to change(Item, :count).by(-1)
  end
end
