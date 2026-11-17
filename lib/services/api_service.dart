import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://amada-api-server-iq.fly.dev";

  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/health')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getHomeData() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/user/home')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> makeOrder({
    required String shopName,
    required String customerName,
    required String customerPhone,
    required String customerLocation,
    required String itemsSummary,
    required int total,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/user/make-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shopName': shopName,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerLocation': customerLocation,
          'itemsSummary': itemsSummary,
          'total': total,
        }),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getOrderStatus(String orderId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/user/order-status/$orderId')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }
}
