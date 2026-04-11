# README

## Setup Guide
```bash
bundle install
rails db:create
rails db:migrate
rails db:seed
rails server
```

Then visit http://localhost:3000.

## Implemented Features
1. **User Auth** _Implemented by: xxx_
    - Secure login (Devise) distinguishing Buyers/Sellers.
2. **Item Lifecycle** _Implemented by: xxx_
   - CRUD with status tracking (Available → Reserved → Sold).
3. **Intelligent Search (PostgreSQL Full-Text)** _Implemented by: xxx_
   - Leveraging pg_search and tsvector for fuzzy search logic. This handles typos (e.g., "Frige" finds "Fridge") and relevance ranking. 
4. **Location-Based Services (Google Maps API)** _Implemented by: xxx_
   - Interactive map visualizing seller locations ("Nearby Sellers") to help students plan logistical exchanges based on proximity. 
5. **Real-time Messaging (ActionCable/WebSockets)** _Implemented by: xxx_
   - In-app chat allowing instant 
negotiation and privacy protection (no phone number exchange required). 
1. **Automated Background Workflows** _Implemented by: xxx_
   - Auto-Completion: Transactions auto-complete 48 hours after meetup time if no dispute is raised.
   - Stale Alerts: Auto-notify sellers to renew listings inactive for >30 days.

## SimpleCov report
