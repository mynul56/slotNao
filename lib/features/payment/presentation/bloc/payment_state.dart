import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

final class PaymentInitiated extends PaymentState {
  final PaymentEntity payment;
  const PaymentInitiated(this.payment);
  @override
  List<Object> get props => [payment];
}

final class PaymentCompleted extends PaymentState {
  final PaymentEntity payment;
  const PaymentCompleted(this.payment);
  @override
  List<Object> get props => [payment];
}

final class PaymentFailed extends PaymentState {
  final String message;
  const PaymentFailed(this.message);
  @override
  List<Object> get props => [message];
}
