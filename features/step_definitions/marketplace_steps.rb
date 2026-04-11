Given("a demo user exists") do
  @demo_user = User.find_or_create_by!(email: "cucumber_buyer@cuhk.local") do |user|
    user.password = "password123"
    user.user_name = "Cucumber Buyer"
    user.location = "MTR University Station"
    user.latitude = 22.4133
    user.longitude = 114.2104
    user.college = "Shaw College"
  end
end

Given("a demo seller exists") do
  @demo_seller = User.find_or_create_by!(email: "cucumber_seller@cuhk.local") do |user|
    user.password = "password123"
    user.user_name = "Cucumber Seller"
    user.location = "United College"
    user.latitude = 22.4212
    user.longitude = 114.2093
    user.college = "United College"
  end
end

Given("demo marketplace items exist") do
  owner = @demo_seller || User.find_by!(email: "cucumber_seller@cuhk.local")
  Item.find_or_create_by!(user: owner, title: "Demo iPad") do |item|
    item.description = "iPad for cucumber search test"
    item.price = 2800
    item.category = "Electronics"
    item.location = "United College"
    item.latitude = 22.4212
    item.longitude = 114.2093
    item.stock_quantity = 1
    item.status = "available"
    item.visibility_scope = "campus"
    item.college = owner.college
  end
end

Given("a reserved item exists for automation") do
  seller = @demo_seller || User.find_by!(email: "cucumber_seller@cuhk.local")
  @reserved_item = Item.find_or_create_by!(user: seller, title: "Reserved Automation Item") do |item|
    item.description = "Reserved item for automation test"
    item.price = 400
    item.category = "Books"
    item.location = "United College"
    item.latitude = 22.4212
    item.longitude = 114.2093
    item.stock_quantity = 2
    item.status = "reserved"
    item.reserved_at = 49.hours.ago
    item.visibility_scope = "campus"
    item.college = seller.college
  end

  @reserved_item.update_columns(status: "reserved", reserved_at: 49.hours.ago, stock_quantity: 2)
end

When("I log in with valid credentials") do
  visit "/users/sign_in"
  fill_in "Email", with: "cucumber_buyer@cuhk.local"
  fill_in "Password", with: "password123"
  click_button "Log in"
end

Then("I should see the browse page") do
  expect(page).to have_content("Signed in successfully")
end

When("I search for {string}") do |query|
  visit "/items"
  fill_in "Search items...", with: query
  click_button "Search"
end

Then("I should see search results containing {string}") do |title|
  expect(page).to have_content(title)
end

When("I go to the nearby sellers map") do
  click_link "Nearby Sellers"
end

Then("I should see the nearby sellers page") do
  expect(page).to have_content("Nearby Sellers")
end

When("I open chat with the seller") do
  item = Item.find_by!(title: "Reserved Automation Item")
  visit "/items/#{item.id}"
  click_button "Contact Seller"
end

Then("I should see the conversation page") do
  expect(page).to have_content("Chat with")
end

When("automation jobs are executed") do
  User.find_or_create_by!(email: "system@local") do |user|
    user.password = "password123"
    user.user_name = "System"
    user.location = "CUHK"
    user.latitude = 22.4133
    user.longitude = 114.2104
    user.college = "Shaw College"
  end

  AutoCompleteReservedItemsJob.perform_now
  StaleAlertJob.perform_now
end

Then("the reserved item should be auto-completed") do
  expect(Item.find_by!(title: "Reserved Automation Item").status).to eq("available")
end
