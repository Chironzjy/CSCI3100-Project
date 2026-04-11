# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

system_user = User.find_or_create_by!(email: "system@local") do |u|
  u.password = "password123"
  u.user_name = "System"
  u.location = "0"
  u.latitude = "0"
  u.longitude = "0"
end

if Rails.env.development?
  demo_users = [
    {
      email: "demo_buyer@cuhk.local",
      password: "password123",
      user_name: "Demo Buyer",
      college: "Shaw College",
      location: "MTR University Station",
      latitude: 22.4133,
      longitude: 114.2104
    },
    {
      email: "demo_seller_a@cuhk.local",
      password: "password123",
      user_name: "Demo Seller A",
      college: "Morningside College",
      location: "Morningside College",
      latitude: 22.4182,
      longitude: 114.2056
    },
    {
      email: "demo_seller_b@cuhk.local",
      password: "password123",
      user_name: "Demo Seller B",
      college: "CW Chu College",
      location: "CW Chu College",
      latitude: 22.4161,
      longitude: 114.2068
    },
    {
      email: "demo_seller_c@cuhk.local",
      password: "password123",
      user_name: "Demo Seller C",
      college: "United College",
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093
    }
  ]

  users_by_email = {}
  demo_users.each do |attrs|
    user = User.find_or_initialize_by(email: attrs[:email])
    user.password = attrs[:password]
    user.user_name = attrs[:user_name]
    user.college = attrs[:college]
    user.location = attrs[:location]
    user.latitude = attrs[:latitude]
    user.longitude = attrs[:longitude]
    user.save!
    users_by_email[attrs[:email]] = user
  end

  demo_items = [
    {
      owner: "demo_seller_a@cuhk.local",
      title: "iPad Air 5 (64GB)",
      description: "Used for one semester. Includes charger and protective case.",
      price: 3200,
      category: "Electronics",
      status: "available",
      stock_quantity: 1,
      location: "Morningside College",
      latitude: 22.4182,
      longitude: 114.2056,
      visibility_scope: "campus"
    },
    {
      owner: "demo_seller_b@cuhk.local",
      title: "Linear Algebra Notes Bundle",
      description: "Neat handwritten notes and solved past papers.",
      price: 120,
      category: "Books",
      status: "available",
      stock_quantity: 5,
      location: "CW Chu College",
      latitude: 22.4161,
      longitude: 114.2068,
      visibility_scope: "college_only",
      visibility_college: "CW Chu College"
    },
    {
      owner: "demo_seller_c@cuhk.local",
      title: "Office Chair",
      description: "Comfortable chair for dorm study setup.",
      price: 450,
      category: "Furniture",
      status: "reserved",
      stock_quantity: 2,
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093,
      visibility_scope: "campus",
      reserved_at: 50.hours.ago
    },
    {
      owner: "demo_seller_a@cuhk.local",
      title: "Badminton Racket",
      description: "Good condition, recently restrung.",
      price: 260,
      category: "Sports",
      status: "inactive",
      stock_quantity: 1,
      location: "University Sports Centre",
      latitude: 22.4196,
      longitude: 114.2118,
      visibility_scope: "campus",
      updated_at: 20.days.ago
    },
    {
      owner: "demo_seller_b@cuhk.local",
      title: "Winter Jacket",
      description: "Medium size, very warm, suitable for exchange term.",
      price: 180,
      category: "Clothing",
      status: "inactive",
      stock_quantity: 1,
      location: "New Asia College",
      latitude: 22.4230,
      longitude: 114.2042,
      visibility_scope: "campus",
      updated_at: 35.days.ago
    },
    {
      owner: "demo_seller_c@cuhk.local",
      title: "Mini Fridge",
      description: "Small fridge in working condition, pickup only.",
      price: 700,
      category: "Electronics",
      status: "sold",
      stock_quantity: 0,
      location: "United College",
      latitude: 22.4212,
      longitude: 114.2093,
      visibility_scope: "campus"
    }
  ]

  items_by_title = {}
  demo_items.each do |attrs|
    owner = users_by_email.fetch(attrs[:owner])
    item = owner.items.find_or_initialize_by(title: attrs[:title])
    item.description = attrs[:description]
    item.price = attrs[:price]
    item.category = attrs[:category]
    item.status = attrs[:status]
    item.stock_quantity = attrs[:stock_quantity]
    item.college = owner.college
    item.location = attrs[:location]
    item.latitude = attrs[:latitude]
    item.longitude = attrs[:longitude]
    item.visibility_scope = attrs[:visibility_scope]
    item.visibility_college = attrs[:visibility_college]
    item.reserved_at = attrs[:reserved_at]
    item.save!

    if attrs[:updated_at].present?
      item.update_columns(updated_at: attrs[:updated_at])
    end

    items_by_title[attrs[:title]] = item
  end

  buyer = users_by_email.fetch("demo_buyer@cuhk.local")
  item_for_chat = items_by_title.fetch("iPad Air 5 (64GB)")
  conversation = Conversation.find_or_create_by!(item: item_for_chat, buyer: buyer, seller: item_for_chat.user)

  sample_messages = [
    { user: buyer, body: "Hi, is this iPad still available?" },
    { user: item_for_chat.user, body: "Yes, still available. Can meet near University Station." },
    { user: buyer, body: "Great, can we meet tomorrow at 3pm?" }
  ]

  sample_messages.each do |entry|
    next if conversation.messages.exists?(user: entry[:user], body: entry[:body])

    conversation.messages.create!(user: entry[:user], body: entry[:body])
  end

  puts "Demo seed ready: #{users_by_email.size} users, #{items_by_title.size} items, and sample conversations."
end