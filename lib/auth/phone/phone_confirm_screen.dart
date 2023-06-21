import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:local/auth/phone/phone_confirm_cubit.dart';
import 'package:lottie/lottie.dart';

import '../../constants.dart';
import '../../generated/l10n.dart';
import '../../img.dart';
import '../../repos/phone_confirm_error.dart';
import '../../theme/decorations.dart';
import '../../theme/dimens.dart';
import '../../utils.dart';
import '../../widgets/button_loading.dart';

class PhoneConfirmScreen extends StatefulWidget {
  const PhoneConfirmScreen({Key? key}) : super(key: key);

  @override
  State<PhoneConfirmScreen> createState() => _PhoneConfirmScreenState();
}

class _PhoneConfirmScreenState extends State<PhoneConfirmScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  String? countryCode;
  String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneConfirmCubit, PhoneConfirmState>(
      listener: (context, state) {
        switch (state.status) {
          case PhoneConfirmStatus.initial:
          case PhoneConfirmStatus.codeSentByUser:
          case PhoneConfirmStatus.codeRequested:
          case PhoneConfirmStatus.failure:
            break;
          case PhoneConfirmStatus.phoneLoaded:
            _phoneController.text = state.phoneNumber;
            break;
          case PhoneConfirmStatus.codeConfirmed:
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.of(context).pop();
            });
            break;
          case PhoneConfirmStatus.codeSent:
            _codeFocus.requestFocus();
            break;
          case PhoneConfirmStatus.phoneCodeInvalid:
            _codeController.clear();
            _codeFocus.requestFocus();
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).phone_number_title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(Dimens.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _getWidgets(state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getWidgets(PhoneConfirmState state) {
    switch (state.status) {
      case PhoneConfirmStatus.initial:
      case PhoneConfirmStatus.phoneLoaded:
      case PhoneConfirmStatus.codeRequested:
        return _getPhoneWidgets(state);
      case PhoneConfirmStatus.codeSent:
      case PhoneConfirmStatus.phoneCodeInvalid:
      case PhoneConfirmStatus.codeSentByUser:
        return _getCodeWidgets(state);
      case PhoneConfirmStatus.codeConfirmed:
        return _getSuccessWidgets(state);
      case PhoneConfirmStatus.failure:
        return _getErrorWidgets(state);
    }
  }

  List<Widget> _getPhoneWidgets(PhoneConfirmState state) {
    return [
      Text(
        S.of(context).phone_number_headline,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      IntlPhoneField(
        controller: _phoneController,
        decoration: textFieldDecoration(
          label: S.of(context).profile_phone_number,
        ),
        initialCountryCode: Constants.initialCountryCodePhone,
        initialValue: state.phoneNumber,
        invalidNumberMessage: S.of(context).phone_number_error_invalid,
        onChanged: (phone) {
          phoneNumber = phone.number;
        },
        onCountryChanged: (country) {
          countryCode = "+${country.dialCode}";
        },
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      ElevatedButton(
        onPressed: () {
          context.read<PhoneConfirmCubit>().requestCode(_getPhoneNumber(state));
        },
        child: state.status == PhoneConfirmStatus.codeRequested
            ? const ButtonLoading()
            : Text(S.of(context).phone_number_send_sms_button),
      ),
    ];
  }

  String _getPhoneNumber(PhoneConfirmState state) {
    String? countryCode;
    String? phoneNumber;
    countryCode = this.countryCode ?? Constants.initialCountryDialCodePhone;
    phoneNumber = this.phoneNumber ?? state.phoneNumber;
    return countryCode + phoneNumber;
  }

  List<Widget> _getCodeWidgets(PhoneConfirmState state) {
    return [
      Visibility(
        visible: state.status == PhoneConfirmStatus.phoneCodeInvalid,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            S.of(context).phone_number_error_invalid_code,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      Text(
        S.of(context).phone_number_sms_code_headline,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      TextField(
        controller: _codeController,
        focusNode: _codeFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        autocorrect: false,
        decoration: textFieldDecoration(
            label: S.of(context).phone_number_sms_code_placeholder),
        onChanged: (value) {
          if (value.length == 6) {
            context.read<PhoneConfirmCubit>().confirmCode(value);
          }
        },
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      Visibility(
        visible: state.status == PhoneConfirmStatus.codeSentByUser,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ];
  }

  List<Widget> _getErrorWidgets(PhoneConfirmState state) {
    String error = "";
    String buttonText = "";
    switch (state.error!) {
      case PhoneConfirmError.invalidPhoneNumber:
        error = S.of(context).phone_number_error_invalid;
        buttonText = S.of(context).phone_number_action_retry_generic;
        break;
      case PhoneConfirmError.alreadyInUse:
        error = S.of(context).phone_number_error_already_used;
        buttonText = S.of(context).phone_number_action_contact_support;
        break;
      case PhoneConfirmError.alreadyLinked:
        error = S.of(context).phone_number_error_already_linked;
        buttonText = S.of(context).phone_number_action_contact_support;
        break;
      case PhoneConfirmError.timeout:
        error = S.of(context).phone_number_error_expired_code;
        buttonText = S.of(context).phone_number_action_retry_generic;
        break;
      case PhoneConfirmError.tooManyRequests:
        error = S.of(context).phone_number_error_too_many_tries;
        buttonText = S.of(context).phone_number_action_contact_support;
        break;
      default:
        error = S.of(context).phone_number_error_generic;
        buttonText = S.of(context).phone_number_action_contact_support;
        break;
    }
    return [
      Text(
        error,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      Visibility(
        visible: buttonText.isNotEmpty,
        child: ElevatedButton(
          onPressed: _getErrorAction(state),
          child: Text(buttonText),
        ),
      ),
    ];
  }

  List<Widget> _getSuccessWidgets(PhoneConfirmState state) {
    return [
      Text(
        S.of(context).phone_number_success_headline,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      Center(
        child: Lottie.asset(
          Img.lottieConfirmPerson,
          height: 200,
          width: 200,
        ),
      ),
    ];
  }

  Function()? _getErrorAction(PhoneConfirmState state) {
    switch (state.error!) {
      case PhoneConfirmError.invalidPhoneNumber:
      case PhoneConfirmError.timeout:
        return () {
          _codeController.clear();
          context.read<PhoneConfirmCubit>().retry();
        };
      default:
        return () {
          _codeController.text = "";
          _sendEmail(state);
        };
    }
  }

  _sendEmail(PhoneConfirmState state) {
    Utils.sendSupportEmail(
        subject: S.of(context).phone_number_support_email_subject,
        body: S
            .of(context)
            .phone_number_support_email_body(_getPhoneNumber(state)));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
