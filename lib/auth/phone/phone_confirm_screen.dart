import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:local/auth/phone/phone_confirm_cubit.dart';

import '../../constants.dart';
import '../../generated/l10n.dart';
import '../../repos/phone_confirm_error.dart';
import '../../theme/decorations.dart';
import '../../theme/dimens.dart';
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
  IntlPhoneField? _phoneField;
  String? countryCode;
  String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneConfirmCubit, PhoneConfirmState>(
      listener: (context, state) {
        switch (state.status) {
          case PhoneConfirmStatus.initial:
            break;
          case PhoneConfirmStatus.phoneLoaded:
            _phoneController.text = state.phoneNumber;
            _phoneField?.onChanged?.call(PhoneNumber(
                countryISOCode: "+40",
                countryCode: "RO",
                number: state.phoneNumber));
            break;
          case PhoneConfirmStatus.codeRequested:
            break;
          case PhoneConfirmStatus.failure:
            break;
          case PhoneConfirmStatus.codeConfirmed:
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.of(context).pop();
            });
            break;
          case PhoneConfirmStatus.codeSent:
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
    ];
  }

  List<Widget> _getErrorWidgets(PhoneConfirmState state) {
    String error = "";
    String buttonText = "";
    switch (state.error!) {
      case PhoneConfirmError.invalidCode:
        error = S.of(context).phone_number_error_invalid_code;
        buttonText = S.of(context).phone_number_action_retry_code;
        break;
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
        break;
      case PhoneConfirmError.timeout:
        error = S.of(context).phone_number_error_expired_code;
        buttonText = S.of(context).phone_number_action_retry_code;
        break;
      case PhoneConfirmError.unknown:
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
    ];
  }

  Function()? _getErrorAction(PhoneConfirmState state) {
    switch (state.error!) {
      case PhoneConfirmError.invalidCode:
      case PhoneConfirmError.timeout:
        return () {
          _codeController.text = "";
          context.read<PhoneConfirmCubit>().requestCode(_getPhoneNumber(state));
        };
      case PhoneConfirmError.alreadyInUse:
        return () {
          _codeController.text = "";
          _sendEmail(state);
        };
      case PhoneConfirmError.invalidPhoneNumber:
        return () {
          context.read<PhoneConfirmCubit>().retry();
        };
      case PhoneConfirmError.unknown:
      case PhoneConfirmError.alreadyLinked:
        return null;
    }
  }

  _sendEmail(PhoneConfirmState state) async {
    final Email email = Email(
      body:
          S.of(context).phone_number_support_email_body(_getPhoneNumber(state)),
      subject: S.of(context).phone_number_support_email_subject,
      recipients: [Constants.supportEmail],
      cc: [],
      bcc: [],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
