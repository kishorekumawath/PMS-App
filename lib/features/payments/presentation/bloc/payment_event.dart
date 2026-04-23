import 'package:equatable/equatable.dart';

import '../../domain/usecases/record_payment.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();
}

class LoadPayments extends PaymentEvent {
  const LoadPayments();
  @override
  List<Object?> get props => [];
}

class RecordPaymentEvent extends PaymentEvent {
  final RecordPaymentParams params;
  const RecordPaymentEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class DeletePaymentEvent extends PaymentEvent {
  final String id;
  const DeletePaymentEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class FilterPayments extends PaymentEvent {
  final PaymentFilter filter;
  const FilterPayments(this.filter);
  @override
  List<Object?> get props => [filter];
}

enum PaymentFilter { all, paid, pending, overdue }
