class Client {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final bool isActive;

  Client({this.id, required this.name, required this.email, required this.phone, required this.company, this.isActive = true});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id_cliente'],
      name: json['nombre'] ?? '',
      email: json['correo'] ?? '',
      phone: json['telefono'] ?? '',
      company: json['empresa'] ?? '',
      isActive: json['id_estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_cliente': id,
      'nombre': name,
      'correo': email,
      'telefono': phone,
      'empresa': company,
      'id_estado': isActive ? 1 : 2,
    };
  }
}
