## Backend SMS Flow

Use this guide to wire up the backend service that receives SMS commands from the Flutter app and responds with nearby mechanics.

### 1. Incoming SMS format
The app sends the following payload to your shortcode (default `1999`):
```
HELP <user_phone> LAT:<latitude> LNG:<longitude>
```
Example:
```
HELP 0771234567 LAT:6.9271 LNG:79.8612
```

### 2. Parse request
Extract:
- `user_phone` → reply-to number.
- `latitude`, `longitude` → driver position (decimals).

### 3. Database lookup
The mechanics table must contain:
| Column      | Type        | Example               |
|-------------|-------------|-----------------------|
| id          | uuid/int    | 1                     |
| name        | text        | Sunil Auto Service    |
| phone       | text        | 0771234567            |
| latitude    | decimal     | 6.9271                |
| longitude   | decimal     | 79.8612               |
| area        | text        | Colombo               |
| available   | bool        | true                  |
| rating      | decimal     | 4.8                   |

**Distance filter (≤ 1 km)**:
```sql
SELECT *,
  (
    6371 * acos(
      cos(radians(:lat)) * cos(radians(latitude)) *
      cos(radians(longitude) - radians(:lng)) +
      sin(radians(:lat)) * sin(radians(latitude))
    )
  ) AS distance
FROM mechanics
HAVING distance <= 1
ORDER BY distance ASC;
```

### 4. SMS reply structure
```
Nearest Mechanics (within 1 km):
1. <name> - <phone> (<distance> km)
2. <name> - <phone> (<distance> km)
```
Limit to 5 entries to keep SMS concise. Round distance to 1 decimal.

### 5. Environment variables
Use a `.env` file (template in `.env.example`) to store:
```
DB_HOST=
DB_PORT=
DB_NAME=
DB_USER=
DB_PASSWORD=
BACKEND_SMS_SHORTCODE=1999
```
Load these variables in the backend service—*never* bake them into the Flutter app.

### 6. Flow summary
1. App sends `HELP ...` SMS to shortcode.
2. Backend parses message, queries DB, formats response.
3. Backend sends SMS back to `user_phone`.

