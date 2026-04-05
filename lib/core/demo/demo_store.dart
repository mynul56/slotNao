import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/payment/domain/entities/payment_entity.dart';
import '../../features/profile/domain/entities/profile_entity.dart';

class DemoStore {
  DemoStore._();

  static String profileName = 'Demo User';
  static String profileEmail = 'demo@slotnao.com';
  static String profilePhone = '01700000000';

  static final Map<String, String> _turfNames = {
    'turf-1': 'SlotNao Arena Dhanmondi',
    'turf-2': 'Green Field Uttara',
  };

  static final Map<String, double> _turfPrices = {
    'turf-1': 1800,
    'turf-2': 1500,
  };

  static final List<BookingEntity> _bookings = <BookingEntity>[
    BookingEntity(
      id: 'demo-booking-seed-1',
      turfId: 'turf-1',
      turfName: 'SlotNao Arena Dhanmondi',
      userId: 'demo-user-1',
      slotStart: DateTime.now().add(const Duration(hours: 20)),
      slotEnd: DateTime.now().add(const Duration(hours: 21)),
      totalAmount: 1800,
      status: BookingStatus.confirmed,
      paymentId: 'demo-payment-seed-1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final Map<String, PaymentEntity> _paymentsById = <String, PaymentEntity>{
    'demo-payment-seed-1': PaymentEntity(
      id: 'demo-payment-seed-1',
      bookingId: 'demo-booking-seed-1',
      amount: 1800,
      gateway: PaymentGateway.bkash,
      status: PaymentStatus.completed,
      transactionId: 'TRX-DEMO-SEED-1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  };

  static List<BookingEntity> getBookings({BookingStatus? status}) {
    final list = status == null
        ? _bookings
        : _bookings.where((b) => b.status == status).toList(growable: false);
    final sorted = [...list]
      ..sort((a, b) => b.slotStart.compareTo(a.slotStart));
    return sorted;
  }

  static BookingEntity createBooking({
    required String turfId,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) {
    final id = 'demo-booking-${DateTime.now().millisecondsSinceEpoch}';
    final amount = _turfPrices[turfId] ?? 1700;
    final booking = BookingEntity(
      id: id,
      turfId: turfId,
      turfName: _turfNames[turfId] ?? 'Demo Turf',
      userId: 'demo-user-1',
      slotStart: slotStart,
      slotEnd: slotEnd,
      totalAmount: amount,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
    _bookings.insert(0, booking);
    return booking;
  }

  static BookingEntity? getBookingDetail(String bookingId) {
    for (final booking in _bookings) {
      if (booking.id == bookingId) return booking;
    }
    return null;
  }

  static void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;
    final current = _bookings[index];
    _bookings[index] = BookingEntity(
      id: current.id,
      turfId: current.turfId,
      turfName: current.turfName,
      userId: current.userId,
      slotStart: current.slotStart,
      slotEnd: current.slotEnd,
      totalAmount: current.totalAmount,
      status: BookingStatus.cancelled,
      paymentId: current.paymentId,
      createdAt: current.createdAt,
    );
  }

  static PaymentEntity initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  }) {
    final id = 'demo-payment-${DateTime.now().millisecondsSinceEpoch}';
    final payment = PaymentEntity(
      id: id,
      bookingId: bookingId,
      amount: amount,
      gateway: gateway,
      status: PaymentStatus.initiated,
      createdAt: DateTime.now(),
    );
    _paymentsById[id] = payment;
    return payment;
  }

  static PaymentEntity confirmPayment({
    required String paymentId,
    required String transactionId,
  }) {
    final existing = _paymentsById[paymentId];
    final bookingId = existing?.bookingId ?? 'demo-booking';
    final amount = existing?.amount ?? 1800;
    final gateway = existing?.gateway ?? PaymentGateway.bkash;

    final completed = PaymentEntity(
      id: paymentId,
      bookingId: bookingId,
      amount: amount,
      gateway: gateway,
      status: PaymentStatus.completed,
      transactionId: transactionId,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    _paymentsById[paymentId] = completed;

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      final current = _bookings[index];
      _bookings[index] = BookingEntity(
        id: current.id,
        turfId: current.turfId,
        turfName: current.turfName,
        userId: current.userId,
        slotStart: current.slotStart,
        slotEnd: current.slotEnd,
        totalAmount: current.totalAmount,
        status: BookingStatus.confirmed,
        paymentId: paymentId,
        createdAt: current.createdAt,
      );
    }

    return completed;
  }

  static ProfileEntity getProfile() {
    final total = _bookings.length;
    final completed = _bookings.where((b) => b.status == BookingStatus.completed).length;

    return ProfileEntity(
      id: 'demo-user-1',
      name: profileName,
      phone: profilePhone,
      email: profileEmail,
      role: UserRole.player,
      totalBookings: total,
      completedBookings: completed,
    );
  }

  static ProfileEntity updateProfile({String? name, String? email, String? avatarUrl}) {
    if (name != null && name.trim().isNotEmpty) {
      profileName = name.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      profileEmail = email.trim();
    }

    return ProfileEntity(
      id: 'demo-user-1',
      name: profileName,
      phone: profilePhone,
      email: profileEmail,
      avatarUrl: avatarUrl,
      role: UserRole.player,
      totalBookings: _bookings.length,
      completedBookings: _bookings.where((b) => b.status == BookingStatus.completed).length,
    );
  }
}
