import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/access_log.dart';

class SupabaseService {
  static const String supabaseUrl = "https://sxtejkwxnuxkomrdxhvf.supabase.co/rest/v1/access_logs";
  static const String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4dGVqa3d4bnV4a29tcmR4aHZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNjEzNjMsImV4cCI6MjA3NDczNzM2M30.XIpjm6BVx0k2mvTXq_srOIGX17QyAZ6vS1RUMggL3uo";

  static Future<List<AccessLog>> getAccessLogs() async {
    try {
      final response = await http.get(
        Uri.parse(supabaseUrl),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AccessLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load access logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching access logs: $e');
    }
  }
}