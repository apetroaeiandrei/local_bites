abstract class Metric {
  static const String eventAppStart = "app_start";
  static const String propertyAppStartDuration = "app_start_duration_millis";
  static const String propertyAppStartLoggedIn = "app_start_logged_in";

  static const String event_ = "";
  static const String eventRestaurantsLoaded = "restaurants_loaded";
  static const String eventRestaurantsError = "restaurants_loading_error";
  static const String eventRestaurantsEnter = "restaurants_enter";
  static const String propertyRestaurantsName = "name";
  static const String propertyRestaurantsCount = "count";

  static const String eventOrderUpdate = "order_update";
  static const String propertyOrderStatus = "status";
  static const String propertyOrderCount = "count";

  static const String eventOrderRate = "order_rate";
  static const String propertyOrderLiked = "liked";
  static const String propertyValueOrderClosed = "closed";

  static const String eventProductsInCartDialog = "products_in_cart_dialog";
  static const String eventProductsInCartDialogCancel =
      "products_in_cart_dialog_cancel";
  static const String eventProductsInCartDialogConfirm =
      "products_in_cart_dialog_confirm";

  static const String eventLogout = "logout";
  static const String eventTC = "terms_conditions";

  static const String eventFoodAddToCart = "food_add_to_cart";
  static const String eventFoodIncreaseQuantity = "food_increase_quantity";
  static const String eventFoodDecreaseQuantity = "food_decrease_quantity";
  static const String eventFoodInvalidOptions = "food_invalid_options";

  static const String eventCartIncreaseQuantity = "cart_increase_quantity";
  static const String eventCartDecreaseQuantity = "cart_decrease_quantity";
  static const String eventCartMinOrder = "cart_min_order";
  static const String eventCartPlaceOrder = "cart_place_order";
  static const String eventCartRestaurantClosed = "cart_restaurant_closed";
  static const String eventCartCouriersUnavailable = "cart_couriers_unavailable";
  static const String propertyOrderPrice = "price";
  static const String propertyOrderPaymentType = "payment_type";

  static const String eventAuthError = "auth_error";
  static const String eventAuthLogin = "auth_login";
  static const String eventAuthPhoneLogin = "auth_login_phone";
  static const String eventAuthRegister = "auth_register";
  static const String eventAuthPasswordReset = "auth_password_reset";
  static const String eventRegisterError = "register_error";
  static const String eventRegisterSuccess = "register_success";

  static const String eventOrderDetailsCall = "order_details_call";
  static const String propertyOrderCallStatus = "order_status";

  static const String eventProfileNavigateBackBlock = "profile_navigate_back_block";
  static const String eventProfileSaveSuccess = "profile_save_success";
  static const String eventProfileSaveError = "profile_save_error";
  static const String eventProfileDelete = "profile_delete";
  static const String eventProfileDeleteError = "profile_delete_error";

  static const String eventAddressPermissionExistedGranted = "address_permission_existed_granted";
  static const String eventAddressPermissionRequesting = "address_permission_requesting";
  static const String eventAddressPermissionGranted = "address_permission_granted";
  static const String eventAddressPermissionDenied = "address_permission_denied";
  static const String eventAddressPropertyError = "address_property_error";
  static const String eventAddressStreetSuccess = "address_property_street_success";
  static const String eventAddressStreetError = "address_street_error";
  static const String eventAddressStreetErrorBackend = "address_street_error_backend";
  static const String eventAddressSaveError = "address_save_error";
  static const String eventAddressSaveSuccess = "address_save_success";
  static const String eventAddressLocationError = "address_current_location_error";

  static const String eventRestaurantInfoCall = "restaurant_info_call";

  static const String eventFCMPermissionGranted = "fcm_permission_granted";
  static const String eventFCMPermissionDenied = "fcm_permission_denied";
  static const String eventNotificationsDialogCancel = "fcm_settings_dialog_cancel";
  static const String eventNotificationsDialogConfirm = "fcm_settings_dialog_confirm";

  static const String eventAppVersionDialog = "app_version_dialog";

  static const String eventKnownAddressDialogCancel = "known_address_dialog_cancel";
  static const String eventKnownAddressDialogConfirm = "known_address_dialog_confirm";
  static const String eventUnknownAddressDialogCancel = "unknown_address_dialog_cancel";
  static const String eventUnknownAddressDialogConfirm = "unknown_address_dialog_confirm";
  static const String eventHomeLocationPermissionDialogCancel = "home_location_permission_dialog_cancel";
  static const String eventHomeLocationPermissionDialogConfirm = "home_location_permission_dialog_confirm";
  static const String eventHomeAddressLocationError = "home_address_location_error";

  static const String eventAddressSelected = "address_selected";
  static const String eventAddressDeleted = "address_deleted";
  static const String eventAddressTryDeleteSelected = "address_try_delete_selected";

  static const String eventFeedbackSend = "feedback_send";
  static const String propertyFeedbackIsPositive = "is_positive";
  static const String propertyFeedbackAspects = "aspects";

  static const String eventPaymentCancelled = "payment_cancelled";

  static const String propertyError = "error";
  static const String eventPhoneConfirmRequest = "phone_confirm_request";
  static const String eventPhoneConfirmSuccess = "phone_confirm_success";
  static const String eventPhoneConfirmError = "phone_confirm_error";
  static const String eventPhoneConfirmRetry = "phone_confirm_retry";

  static const String eventPhoneLoginRequest = "phone_login_request";
  static const String eventPhoneLoginSuccess = "phone_login_success";
  static const String eventPhoneLoginError = "phone_login_error";
  static const String eventPhoneLoginRetry = "phone_login_retry";

}
