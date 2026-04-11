require "rails_helper"

RSpec.describe Item, type: :model do
  let(:user) do
    User.create!(
      email: "rspec_item_owner@cuhk.local",
      password: "password123",
      user_name: "RSpec Item Owner",
      location: "MTR University Station",
      latitude: 22.4133,
      longitude: 114.2104,
      college: "Shaw College"
    )
  end

  it "finalizes reserved item to available when stock remains" do
    item = Item.create!(
      user: user,
      title: "RSpec Chair",
      description: "Chair for lifecycle test",
      price: 100,
      category: "Furniture",
      location: "Shaw College",
      latitude: 22.414,
      longitude: 114.21,
      stock_quantity: 2,
      status: "reserved",
      reserved_at: 49.hours.ago,
      visibility_scope: "campus"
    )

    item.finalize_reservation!
    item.reload

    expect(item.status).to eq("available")
    expect(item.stock_quantity).to eq(1)
    expect(item.reserved_at).to be_nil
  end

  it "sets sold when stock is zero" do
    item = Item.create!(
      user: user,
      title: "RSpec Jacket",
      description: "Jacket for stock test",
      price: 90,
      category: "Clothing",
      location: "Shaw College",
      latitude: 22.414,
      longitude: 114.21,
      stock_quantity: 0,
      status: "available",
      visibility_scope: "campus"
    )

    item.valid?
    expect(item.status).to eq("sold")
  end
end
