class RegisterResponse {
  final bool success;
  final String message;
  final String? idCustomer;

  RegisterResponse({
    required this.success, 
    required this.message, 
    this.idCustomer
  });

  // Manual Factory: Mengubah JSON dari API jadi Object
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      idCustomer: json['id_customer']?.toString(), // Handle jika id_customer null
    );
  }
}