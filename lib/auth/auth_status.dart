enum AuthStatus {
  initial,
  authorized,
  unauthorized,
  loadingEmail,
  phoneCodeRequested,
  phoneCodeSent,
  phoneCodeConfirmed,
  phoneCodeInvalid,
  phoneCodeSentByUser,
  phoneAuthError,
}