# Flutter BLoC Integration With Production Backend

## Request flow

UI -> Event -> Bloc -> UseCase -> Repository -> RemoteDatasource -> REST/WebSocket -> State -> UI

## Auth module

- Request OTP: `POST /auth/otp`
- Login: `POST /auth/login`
- Refresh: `POST /auth/refresh`
- Logout: `POST /auth/logout`
- Current user: `GET /auth/me`

### Flutter adjustments

- Replace password login payload with OTP payload:
  - current: `{phone, password}`
  - target: `{phone, otp}`

## Turf module

- List turfs: `GET /turfs?page=1&pageSize=20`
- Turf detail: `GET /turfs/:id`
- Slots by date: `GET /turfs/:id/slots?date=YYYY-MM-DD`

## Booking module

- Create booking lock: `POST /bookings` with `{turf_id, slot_id}`
- List bookings: `GET /bookings?status=confirmed`

### State handling recommendation

- On create success (`pending payment`), transition to payment flow immediately.
- If API returns 409, show real-time stale-slot message and refetch slots.

## Payment module

- Initiate: `POST /payments/init` with `{booking_id, amount, method}`
- Confirm: `POST /payments/confirm` with `{booking_id, provider_transaction_id, status}`

### Rule

- UI must not display booking confirmed until `/payments/confirm` returns success.

## WebSocket slots integration

- Connect on turf detail page:
  - `/ws?turfId=<id>`
- React to event types:
  - `slot_locked`, `slot_unlocked`, `slot_booked`

### BLoC mapping

- WS event -> `SlotAvailabilityUpdated` event
- Bloc merges optimistic selection with incoming updates
- If selected slot becomes unavailable, clear selection and notify user

## Role-based navigation

- `role` from token/current user drives landing:
  - `user` -> player app
  - `owner` -> owner console
  - `admin` -> admin control center
