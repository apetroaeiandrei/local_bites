enum AuthStatus {
  initial,
  authorized,
  invalidEmailCredentials,
  loadingEmail,
  passwordResetRequested,
  passwordResetError,
  phoneCodeRequested,
  phoneCodeSent,
  phoneCodeConfirmed,
  phoneCodeInvalid,
  phoneCodeSentByUser,
  phoneAuthError,
}