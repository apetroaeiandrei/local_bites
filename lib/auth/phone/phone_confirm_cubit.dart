import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'phone_confirm_state.dart';

class PhoneConfirmCubit extends Cubit<PhoneConfirmState> {
  PhoneConfirmCubit() : super(PhoneConfirmInitial());
}
