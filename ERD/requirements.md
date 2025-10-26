# ALX Airbnb Database - ERD Requirements

## Entities (summary)
- **users**
  - `user_id` PK, full name, email, phone, role (guest/host/admin), created_at
- **cities**
  - `city_id` PK, name, country, region
- **properties**
  - `property_id` PK, owner_id FK -> users.user_id, title, description, city_id FK -> cities.city_id, address, price_per_night, currency, created_at
- **amenities**
  - `amenity_id` PK, name
- **property_amenities**
  - associative table linking properties and amenities
- **property_images**
  - `image_id` PK, property_id FK, url, caption, is_primary
- **bookings**
  - `booking_id` PK, user_id FK (guest), property_id FK, start_date, end_date, nights, total_amount, status
- **payments**
  - `payment_id` PK, booking_id FK, amount, currency, method, status, paid_at
- **reviews**
  - `review_id` PK, booking_id FK, reviewer_id FK -> users.user_id, rating, comment, created_at

## Relationships (summary)
- **users (1) — (N) properties** : a user (host) can own many properties.
- **users (1) — (N) bookings** : a user (guest) can make many bookings.
- **properties (1) — (N) bookings** : a property can have many bookings.
- **bookings (1) — (1) payments** : each booking can have one or more payments (one-to-many); for simplicity we assume one payment per booking here.
- **properties (N) — (N) amenities** : many-to-many via `property_amenities`.
- **properties (1) — (N) property_images** : images for each property.
- **bookings (1) — (1..N) reviews** : a booking may result in a review; reviewer is a user (guest) and targets the property/host.

## Notes for ERD drawing
- Use crow's foot notation if available.
- Mark PKs and FKs clearly.
- Show attributes for each entity (at least the columns listed).
- Indicate cardinalities (1-to-many, many-to-many).
