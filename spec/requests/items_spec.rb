require "rails_helper"

RSpec.describe "Items", type: :request do
  let!(:user) do
    User.create!(
      email: "rspec_request_user@cuhk.local",
      password: "password123",
      user_name: "RSpec Request User",
      location: "MTR University Station",
      latitude: 22.4133,
      longitude: 114.2104,
      college: "Shaw College"
    )
  end

  let!(:item) do
    Item.create!(
      user: user,
      title: "RSpec Search iPad",
      description: "iPad for request search",
      price: 3000,
      category: "Electronics",
      location: "Shaw College",
      latitude: 22.414,
      longitude: 114.21,
      stock_quantity: 1,
      status: "available",
      visibility_scope: "campus"
    )
  end

  before { sign_in user }

  it "returns filtered search results in index" do
    get items_path, params: { search: "iPad" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(item.title)
  end

  it "renders map page" do
    get map_items_path, params: { radius: 5 }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Nearby Sellers")
  end

  it "blocks access to another college-only item" do
    other_user = User.create!(
      email: "rspec_request_other@cuhk.local",
      password: "password123",
      user_name: "RSpec Other User",
      location: "Morningside College",
      latitude: 22.4182,
      longitude: 114.2056,
      college: "Morningside College"
    )

    restricted_item = Item.create!(
      user: other_user,
      title: "Restricted Notebook",
      description: "Visible only in another college",
      price: 60,
      category: "Books",
      location: "Morningside College",
      latitude: 22.4182,
      longitude: 114.2056,
      stock_quantity: 1,
      status: "available",
      visibility_scope: "college_only",
      visibility_college: "Morningside College"
    )

    get item_path(restricted_item)

    expect(response).to redirect_to(items_path)
  end
end
