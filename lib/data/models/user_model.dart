class UserModel {
  final int? id;
  final String nombre;
  final String correo;
  final String clave;
  final String rol; // 'emisor' o 'inversor'

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.clave,
    required this.rol,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        nombre: json['nombre'],
        correo: json['correo'],
        clave: json['clave'],
        rol: json['rol'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'clave': clave,
        'rol': rol,
      };
}
