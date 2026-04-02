# SlotNao Production System Architecture

## 1. High-level architecture

- Flutter app (BLoC + Clean Architecture)
- API Gateway (Express)
- Domain services (Auth, Turf, Booking, Payment, Admin)
- PostgreSQL for source of truth
- Redis for distributed locks and short-lived states
- WebSocket hub for live slot updates

## 2. Multi-role boundaries

- User (player): browse, lock slot, pay, booking history
- Owner: turf and slot management, occupancy and earnings
- Admin: approve turf, block users, monitor bookings, disputes

Role checks are enforced in backend middleware via JWT claims.

## 3. Booking conflict prevention

Three-layer protection:

1. Redis NX lock (`slot_lock:<slot_id>`) with 30-second TTL.
2. PostgreSQL transaction with `SELECT ... FOR UPDATE` on slot row.
3. Partial unique index on active bookings per slot:
   - status in (`pending`, `confirmed`, `completed`).

Outcome: race-safe booking confirmation under high concurrency.

## 4. Payment-first confirmation

- Booking starts in `pending` state.
- Payment status starts `initiated/pending`.
- Booking moves to `confirmed` only after `payments/confirm` with `paid`.
- If payment fails, booking becomes `failed` and lock is released.

## 5. WebSocket real-time contract

Client connection:

- `ws://<host>/ws?turfId=<turf_id>` for slot changes
- `ws://<host>/ws?userId=<user_id>` for personal booking updates

Events:

- `slot_locked`
- `slot_unlocked`
- `slot_booked`
- `booking_pending_payment`

## 6. Security

- JWT access/refresh
- OTP login flow with Redis TTL
- RBAC middleware
- Zod request validation
- Rate limiting on auth and booking endpoints
- Helmet + CORS + request-id tracing

## 7. Scalability

- Stateless API pods behind load balancer
- Redis shared lock state for all pods
- PostgreSQL with read replicas for analytics workloads
- CDN for media delivery
- Background jobs for payout/dispute SLA alerts

## 8. Testing strategy

- Unit: services (locking, payment transition, RBAC)
- API integration: auth, booking, payment, admin flows
- Load: concurrent booking attempts against same slot
- WebSocket contract tests for slot events
