import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/delete_payment.dart';
import '../../domain/usecases/get_all_payments.dart';
import '../../domain/usecases/mark_payment_as_paid.dart';
import '../../domain/usecases/record_payment.dart';
import 'payment_event.dart';
import 'payment_state.dart';

export 'payment_event.dart';
export 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetAllPayments _getAll;
  final RecordPayment _record;
  final DeletePayment _delete;
  final MarkPaymentAsPaid _markPaid;

  PaymentFilter _activeFilter = PaymentFilter.all;

  PaymentBloc({
    required GetAllPayments getAll,
    required RecordPayment record,
    required DeletePayment delete,
    required MarkPaymentAsPaid markPaid,
  })  : _getAll = getAll,
        _record = record,
        _delete = delete,
        _markPaid = markPaid,
        super(const PaymentInitial()) {
    on<LoadPayments>(_onLoad);
    on<RecordPaymentEvent>(_onRecord);
    on<DeletePaymentEvent>(_onDelete);
    on<MarkPaymentAsPaidEvent>(_onMarkPaid);
    on<FilterPayments>(_onFilter);
  }

  List<Payment> _applyFilter(List<Payment> all, PaymentFilter filter) {
    final now = DateTime.now();
    return switch (filter) {
      PaymentFilter.all => all,
      PaymentFilter.paid =>
        all.where((p) => p.status == PaymentStatus.paid).toList(),
      PaymentFilter.pending => all
          .where((p) =>
              p.status == PaymentStatus.pending && !p.dueDate.isBefore(now))
          .toList(),
      PaymentFilter.overdue => all
          .where((p) =>
              p.status == PaymentStatus.overdue ||
              (p.status == PaymentStatus.pending && p.dueDate.isBefore(now)))
          .toList(),
    };
  }

  Future<void> _reload(Emitter<PaymentState> emit) async {
    final all = await _getAll(const NoParams());
    emit(PaymentLoaded(
      allPayments: all,
      filteredPayments: _applyFilter(all, _activeFilter),
      activeFilter: _activeFilter,
    ));
  }

  Future<void> _onLoad(LoadPayments event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    try {
      await _reload(emit);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onRecord(
      RecordPaymentEvent event, Emitter<PaymentState> emit) async {
    try {
      await _record(event.params);
      await _reload(emit);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeletePaymentEvent event, Emitter<PaymentState> emit) async {
    try {
      await _delete(event.id);
      await _reload(emit);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onMarkPaid(
      MarkPaymentAsPaidEvent event, Emitter<PaymentState> emit) async {
    try {
      await _markPaid(event.id);
      await _reload(emit);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onFilter(
      FilterPayments event, Emitter<PaymentState> emit) async {
    _activeFilter = event.filter;
    if (state is PaymentLoaded) {
      final all = (state as PaymentLoaded).allPayments;
      emit(PaymentLoaded(
        allPayments: all,
        filteredPayments: _applyFilter(all, _activeFilter),
        activeFilter: _activeFilter,
      ));
    }
  }
}
