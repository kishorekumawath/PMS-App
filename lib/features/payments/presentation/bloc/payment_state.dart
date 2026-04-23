import 'package:equatable/equatable.dart';

import '../../domain/entities/payment.dart';
import 'payment_event.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
  @override
  List<Object?> get props => [];
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
  @override
  List<Object?> get props => [];
}

class PaymentLoaded extends PaymentState {
  final List<Payment> allPayments;
  final List<Payment> filteredPayments;
  final PaymentFilter activeFilter;

  const PaymentLoaded({
    required this.allPayments,
    required this.filteredPayments,
    required this.activeFilter,
  });

  @override
  List<Object?> get props => [allPayments, filteredPayments, activeFilter];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
