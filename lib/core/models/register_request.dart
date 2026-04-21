class RegisterRequest {
  final String namaCustomer;
  final String emailCustomer;
  final String noTelp;
  final String passwordCustomer;

  RegisterRequest(this.namaCustomer, this.emailCustomer, this.noTelp, this.passwordCustomer);

  // Manual toJson: Nggak butuh .g.dart lagi
  Map<String, dynamic> toJson() {
    return {
      'nama_customer': namaCustomer,
      'email_customer': emailCustomer,
      'no_tlp': noTelp,
      'password_customer': passwordCustomer,
    };
  }
}