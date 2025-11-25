import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/access_log.dart';

class SupabaseService {
  // Supabase configuration - using the provided values
  static const String supabaseProjectUrl = "sxtejkwxnuxkomrdxhvf.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4dGVqa3d4bnV4a29tcmR4aHZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNjEzNjMsImV4cCI6MjA3NDczNzM2M30.XIpjm6BVx0k2mvTXq_srOIGX17QyAZ6vS1RUMggL3uo";

  // Table name
  static const String tableName = "access_logs";

  // Construct the full URL
  static String get supabaseUrl => "https://$supabaseProjectUrl/rest/v1/$tableName";

  static Future<List<AccessLog>> getAccessLogs() async {
    try {
      final response = await http.get(
        Uri.parse(supabaseUrl),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation', // Return the data after the operation
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AccessLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load access logs: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      // Handle network-related errors
      throw Exception('Network error: ${e.message}. Please check your internet connection and Supabase configuration.');
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      throw Exception('Response format error: ${e.message}. The response from Supabase is not in the expected format.');
    } catch (e) {
      // Handle other errors
      throw Exception('Error fetching access logs: $e');
    }
  }
}