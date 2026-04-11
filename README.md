# CUHK Mart

## Setup Guide (Run the Product)

```bash
bundle install
bundle exec rails db:create
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails server -b 127.0.0.1 -p 3000
```

Open `http://127.0.0.1:3000` in your browser.

### Environment Notes

- Ruby: 3.4.x
- Database: PostgreSQL
- If location autocomplete/map does not work, set `GOOGLE_MAPS_API_KEY` in `.env`.

## Test Guide (Test the Product)

Run the automated test suite:

```bash
bundle exec rails test
bundle exec rspec
bundle exec cucumber
```

Run targeted automation tests:

```bash
bundle exec rails test test/jobs/auto_complete_reserved_items_job_test.rb test/jobs/stale_alert_job_test.rb
```

To verify scheduled jobs manually in development:

```bash
bundle exec rails runner "AutoCompleteReservedItemsJob.perform_now"
bundle exec rails runner "StaleAlertJob.perform_now"
```

## Demo Data and Smoke Checklist

After running `bundle exec rails db:seed` in development, the following demo accounts are available:

- `demo_buyer@cuhk.local` / `password123`
- `demo_seller_a@cuhk.local` / `password123`
- `demo_seller_b@cuhk.local` / `password123`
- `demo_seller_c@cuhk.local` / `password123`

Recommended smoke test order:

1. Log in as `demo_buyer@cuhk.local` and verify browse/search/filter results.
2. Open map view and confirm nearby seller cards/markers render.
3. Open an item and start chat with seller; confirm conversation updates.
4. Log in as seller and verify listing lifecycle actions (`available`/`reserved`/`inactive`).
5. Run automation jobs manually and verify outcomes:
   - `bundle exec rails runner "AutoCompleteReservedItemsJob.perform_now"`
   - `bundle exec rails runner "StaleAlertJob.perform_now"`
6. Confirm system messages appear in related conversations.

## Implemented Features and Ownership

Team members:
- MA Zizhan (`zzma2`)
- LI Zhengyang (`LI-Zhengyang-00`)
- ZHANG Junyuan (`Chironzjy`)
- Lau Ho Cheong (`AndyLau-Rei`)
- YE Yangtao (`YangTaoYe`)

| Feature | Description | Primary Developer | Secondary Developer |
| --- | --- | --- | --- |
| User Authentication (Devise) | Sign up, login, account settings, profile fields | Team | Team |
| Item Lifecycle Management | CRUD + status transitions (`available`, `reserved`, `inactive`, `sold`) | Team | Team |
| Intelligent Search | Fuzzy search via `pg_search` + filters | Team | Team |
| Location-Based Discovery | Nearby sellers/map view with location fallback | Team | Team |
| Real-time Messaging | ActionCable buyer-seller chat per listing | Team | Team |
| Automated Workflows | 48h auto-completion, 15d inactive reminder, 30d inactive cleanup | Team | Team |

## Implemented Feature Details

1. **User Authentication (Devise)**
   - Users can sign up, log in, and manage account settings.
   - Username is unique and profile includes location/college fields.

2. **Item Lifecycle Management**
   - Full item CRUD with status transitions (`available`, `reserved`, `inactive`, `sold`).
   - Stock quantity and reserve timestamp are tracked for automation.

3. **Intelligent Search**
   - `pg_search` powers fuzzy search over title/description/location.
   - Category and college filters are supported in the browse page.

4. **Location-Based Discovery**
   - Google Maps page shows nearby listings/sellers with configurable radius.
   - Fallback list mode is available when user coordinates are missing.

5. **Real-time Messaging**
   - ActionCable chat between buyer and seller inside each conversation.
   - Listing-specific conversations are scoped by participants and item.

6. **Automated Background Workflows**
   - **Auto-Completion**: reserved items are automatically finalized after 48 hours.
   - **Inactive Reminder**: items inactive for more than 15 days trigger a system reminder.
   - **Inactive Cleanup**: items inactive for more than 30 days are automatically removed.
   - Background jobs are scheduled through recurring jobs configuration.

## SimpleCov Report Screenshot

After running coverage, place the screenshot at `docs/simplecov-report.png` and keep the image below.

![SimpleCov Coverage Report](docs/simplecov-report.png)

## Notes

- The project currently uses recurring Active Job scheduling in `config/recurring.yml`.
- Seed data creates a `system@local` user for automation messages.
- CI should pass all security/lint/test jobs before final submission.

## Quick Verification for TAs

Use this short path to verify advanced features quickly:

1. Sign in with `demo_buyer@cuhk.local`.
2. Search `iPad` in browse page and open item details.
3. Start chat and send one message.
4. Trigger `AutoCompleteReservedItemsJob` and refresh conversations.
5. Trigger `StaleAlertJob` and verify stale reminder/cleanup effects.
