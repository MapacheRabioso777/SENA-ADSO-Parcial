import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio centralizado para comunicarse con la API Node.js.
class ApiService {
  // URL base de la API — cambiar si el servidor corre en otro host/puerto
  static const String _baseUrl = 'http://localhost:3000/api_v1';

  // ─────────────────────────────────────────────────────────────────────
  // LOGIN
  // POST /apiUserLogin  → body: { api_user, api_password }
  //                     ← { token }
  // ─────────────────────────────────────────────────────────────────────
  static Future<ApiResult> loginUser({
    required String apiUser,
    required String apiPassword,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/userLogin');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user': apiUser,
              'password': apiPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'] as String;
        return ApiResult.success(token);
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error'] ?? 'Credenciales incorrectas';
        return ApiResult.failure(msg);
      }
    } catch (e) {
      return ApiResult.failure(_networkError(e));
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // ESTADO DE USUARIO
  // GET /userStatus  → Header: Authorization: Bearer <token>
  //                 ← List<{ User_status_id, User_status_name, User_status_description }>
  // ─────────────────────────────────────────────────────────────────────
  static Future<ApiResult> getUserStatuses(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/userStatus');
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        final statuses = body
            .map((e) => UserStatus.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(statuses);
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error'] ?? 'Error al obtener estados';
        return ApiResult.failure(msg);
      }
    } catch (e) {
      return ApiResult.failure(_networkError(e));
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // CREAR ESTADO
  // POST /userStatus  → body: { name, description }
  // ─────────────────────────────────────────────────────────────────────
  static Future<ApiResult> addUserStatus({
    required String token,
    required String name,
    required String description,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/userStatus');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return ApiResult.success(null);
      } else {
        final body = jsonDecode(response.body);
        return ApiResult.failure(body['error'] ?? 'Error al crear estado');
      }
    } catch (e) {
      return ApiResult.failure(_networkError(e));
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helper: mensaje de error de red amigable
  // ─────────────────────────────────────────────────────────────────────
  static String _networkError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'No se pudo conectar al servidor. ¿Está corriendo la API?';
    }
    if (msg.contains('TimeoutException')) {
      return 'La conexión tardó demasiado. Intente de nuevo.';
    }
    return 'Error de red: $msg';
  }
}

// ───────────────────────────────────────────────────────────────────────
// Resultado genérico de una llamada a la API
// ───────────────────────────────────────────────────────────────────────
class ApiResult {
  final bool ok;
  final dynamic data;   // token (String) o lista (List<UserStatus>) según el caso
  final String? error;

  const ApiResult._({required this.ok, this.data, this.error});

  factory ApiResult.success(dynamic data) =>
      ApiResult._(ok: true, data: data);

  factory ApiResult.failure(String error) =>
      ApiResult._(ok: false, error: error);
}

// ───────────────────────────────────────────────────────────────────────
// Modelo de UserStatus
// ───────────────────────────────────────────────────────────────────────
class UserStatus {
  final int id;
  final String name;
  final String description;

  const UserStatus({
    required this.id,
    required this.name,
    required this.description,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      id: json['User_status_id'] as int,
      name: (json['User_status_name'] ?? '').toString(),
      description: (json['User_status_description'] ?? '').toString(),
    );
  }
}
