## RoadResQ SMS Backend

Backend service for handling offline emergency requests via Android device connected via USB (ADB).

### Prerequisites
1. Node.js 18+
2. MySQL database with a `mechanics` table containing:
   - `id`, `name`, `phone`, `latitude`, `longitude`, `area`, `available`, `rating`
3. Android device connected via USB with:
   - Developer mode enabled
   - USB debugging enabled
   - ADB installed on your development machine

### Setup
```bash
cd backend
npm install
npm run dev
```

Environment variables (optional, defaults shown):
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=roadresq
DB_USER=root
DB_PASSWORD=your_password
MAX_RADIUS_KM=1
PORT=3000
BACKEND_PHONE_NUMBER=0715562360  # Your development phone number
```

### Flow

#### Step 1: User clicks "Help" button
- Flutter app sends `POST /sms` with:
  ```json
  {
    "userPhone": "0771234567",
    "latitude": 6.9271,
    "longitude": 79.8612
  }
  ```
- Backend opens SMS app on connected Android device with message:
  ```
  HELP 0771234567 LAT:6.9271 LNG:79.8612
  ```
- Message is addressed to `BACKEND_PHONE_NUMBER`
- **You manually send this message from your development phone**

#### Step 2: Get mechanics list
- After sending the message, call `POST /sms-response` with the same data:
  ```json
  {
    "userPhone": "0771234567",
    "latitude": 6.9271,
    "longitude": 79.8612
  }
  ```
- Backend queries MySQL for nearby mechanics (within 1 km)
- Backend opens SMS app on Android device with formatted mechanics list
- Message is addressed to the user's phone number
- **You manually send this message to the user**

### Endpoints

- `POST /sms` - Opens SMS app with request message
- `POST /sms-response` - Queries DB and opens SMS app with mechanics list
- `GET /health` - Health check endpoint

### Response Format
The mechanics list SMS will be formatted as:
```
Nearest Mechanics (within 1 km):
1. Sunil Auto Service - 0771234567 (0.8 km)
2. Kamal Motors - 0772345678 (0.9 km)
```

### Testing
1. Connect Android device via USB
2. Enable USB debugging
3. Start backend: `npm run dev`
4. Test with: `curl -X POST http://localhost:3000/sms -H "Content-Type: application/json" -d '{"userPhone":"0771234567","latitude":6.9271,"longitude":79.8612}'`
