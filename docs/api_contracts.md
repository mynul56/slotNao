# API Contracts (Production Baseline)

## Auth

### POST /auth/otp

Request:

```json
{ "phone": "+8801700000003" }
```

Response:

```json
{ "message": "otp_sent", "data": { "ttlSeconds": 180 } }
```

### POST /auth/login

Request:

```json
{ "phone": "+8801700000003", "otp": "123456" }
```

Response:

```json
{
  "message": "login_success",
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "user": { "id": "...", "name": "...", "phone": "...", "role": "user" }
  }
}
```

## Turf

### GET /turfs

Response list of approved turfs.

### GET /turfs/:id/slots?date=YYYY-MM-DD

Response:

```json
{
  "message": "slot_list",
  "data": [
    {
      "id": "...",
      "turf_id": "...",
      "date": "2026-04-02",
      "time": "19:00:00",
      "is_booked": false
    }
  ]
}
```

## Booking

### POST /bookings

Request:

```json
{ "turf_id": "...", "slot_id": "..." }
```

Responses:

- `201 booking_created_pending_payment`
- `409 slot_locked_by_another_user` or `slot_already_booked`

## Payment

### POST /payments/init

Request:

```json
{ "booking_id": "...", "amount": 2000, "method": "bkash" }
```

### POST /payments/confirm

Request:

```json
{ "booking_id": "...", "provider_transaction_id": "TX123", "status": "paid" }
```

## Admin

- POST `/admin/turfs/:turfId/approve`
- POST `/admin/users/:userId/block`
- GET `/admin/bookings`
- GET `/admin/disputes`
