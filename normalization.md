# Normalization: ALX Airbnb Database

## Starting point (unnormalized)
A typical naive table might store redundant city names with each property, duplicate host info in property rows, or repeated amenity names as comma-separated values — all of which violate normalization.

## Goal
Bring schema to **3rd Normal Form (3NF)**:
1. 1NF — atomic values, no repeating groups.
2. 2NF — remove partial dependencies (no non-key attribute depends on part of a composite key).
3. 3NF — remove transitive dependencies (non-key attribute depends on another non-key attribute).

## Steps taken
1. **Separate Users** — `users` holds person details. No duplication across bookings/properties.
2. **Separate Cities** — `cities` table to avoid repeating city/country strings in `properties`.
3. **Properties** only references `cities` and `users` (owner). All property-specific attributes are stored here.
4. **Amenities** moved to their own table; `property_amenities` is the join table. This removes comma-separated lists and repeated amenity text.
5. **Payments** associate to `bookings` using foreign keys, avoiding storing payment info with booking rows.
6. **Reviews** reference `bookings` + `reviewer_id` to avoid storing reviewer info redundantly.
7. **Property images** placed in `property_images` table.

All non-key attributes depend only on the primary key of their table — satisfies 3NF.

## Final normalized schema (table list & key columns)
- `users(user_id PK, full_name, email UNIQUE, phone, role, created_at)`
- `cities(city_id PK, name, country, region)`
- `properties(property_id PK, owner_id FK -> users.user_id, city_id FK -> cities.city_id, title, description, address, price_per_night, currency, created_at)`
- `amenities(amenity_id PK, name UNIQUE)`
- `property_amenities(property_id FK, amenity_id FK, PRIMARY KEY(property_id, amenity_id))`
- `property_images(image_id PK, property_id FK, url, caption, is_primary, created_at)`
- `bookings(booking_id PK, user_id FK, property_id FK, start_date, end_date, nights, total_amount, status, created_at)`
- `payments(payment_id PK, booking_id FK, amount, currency, method, status, paid_at)`
- `reviews(review_id PK, booking_id FK, reviewer_id FK, rating, comment, created_at)`

## Conclusion
This design removes redundancy and update anomalies and is in **3NF**. Use indexes on FK columns and frequently queried columns (e.g., `properties.city_id`, `bookings.property_id`) for performance.
