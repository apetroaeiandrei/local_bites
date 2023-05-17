import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'vouchers_state.dart';

class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit() : super(VouchersInitial());
}
