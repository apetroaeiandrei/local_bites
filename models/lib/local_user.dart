class LocalUser {
  final String name;
  final String email;
  final String uid;
  final String phoneNumber;
  final bool phoneVerified;
  final String referralCode;
  final String? street;
  final String? propertyDetails;
  final String? zipCode;

//<editor-fold desc="Data Methods">
  const LocalUser({
    required this.name,
    required this.email,
    required this.uid,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.referralCode,
    this.street,
    this.propertyDetails,
    this.zipCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          uid == other.uid &&
          phoneNumber == other.phoneNumber &&
          phoneVerified == other.phoneVerified &&
          referralCode == other.referralCode &&
          street == other.street &&
          propertyDetails == other.propertyDetails &&
          zipCode == other.zipCode
      );

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      uid.hashCode ^
      phoneNumber.hashCode ^
      phoneVerified.hashCode ^
      referralCode.hashCode ^
      street.hashCode ^
      propertyDetails.hashCode ^
      zipCode.hashCode
  ;

  @override
  String toString() {
    return 'LocalUser{' +
        ' name: $name,' +
        ' email: $email,' +
        ' uid: $uid,' +
        ' phoneNumber: $phoneNumber,' +
        ' phoneVerified: $phoneVerified,' +
        ' referralCode: $referralCode,' +
        ' street: $street,' +
        ' propertyDetails: $propertyDetails,' +
        ' zipCode: $zipCode,' +
        '}';
  }

  LocalUser copyWith({
    String? name,
    String? email,
    String? uid,
    String? phoneNumber,
    bool? phoneVerified,
    String? referralCode,
    String? street,
    String? propertyDetails,
    String? zipCode,
  }) {
    return LocalUser(
      name: name ?? this.name,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      referralCode: referralCode ?? this.referralCode,
      street: street ?? this.street,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      zipCode: zipCode ?? this.zipCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'referralCode': referralCode,
      'street': street,
      'propertyDetails': propertyDetails,
      'zipCode': zipCode,
    };
  }

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] ?? "",
      phoneVerified: map['phoneVerified'] ?? false,
      referralCode: map['referralCode'] ?? "",
      street: map['street'] as String?,
      propertyDetails: map['propertyDetails'] as String?,
      zipCode: map['zipCode'] as String?,
    );
  }

//</editor-fold>
}
