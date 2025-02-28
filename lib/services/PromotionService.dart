import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectlavage/models/service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../models/promotion.dart';

class PromotionService {
  final String apiUrl = 'http://192.168.1.14:8085/api/promotions';

  Future<List<Promotion>> fetchPromotions() async {
    // Retrieve the stored token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // Ensure the token is available
    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    // Set the headers to include the token
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Make the API request with the token in the header
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> jsonResponse = json.decode(response.body);
      // Map the JSON to Promotion objects
      return jsonResponse.map((json) => Promotion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load promotions');
    }
  }

  Future<String> deletePromotion(int promotionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(
      Uri.parse('$apiUrl/delete/$promotionId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return 'Promotion supprimée avec succès';
    } else {
      throw Exception('Échec de la suppression de la promotion');
    }
  }

  Future<String> addPromotion(Promotion promotion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(promotion.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return 'Promotion ajoutée avec succès';
    } else {
      throw Exception("Échec de l'ajout de la promotion: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> updatePromotion(
      int promotionId, Promotion promotion) async {
    try {
      // Récupérer le token JWT
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      // Définir les en-têtes de la requête
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Convertir l'objet Promotion en JSON
      final body = jsonEncode(promotion.toJson());

      // Effectuer la requête PUT
      final response = await http.put(
        Uri.parse('$apiUrl/update/$promotionId'),
        headers: headers,
        body: body,
      );

      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        // Convertir la réponse JSON en Map<String, dynamic>
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update promotion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<Service>> fetchServices() async {
    String? token = await getToken();
    print("TOKEN: $token");

    final response = await http.get(
      Uri.parse("$apiUrl/servicesWithPromotions"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    } else {
      throw Exception("Échec du chargement des services");
    }
  }

  Future<int> getPromotionCount() async {
    try {
      List<Promotion> promotions = await fetchPromotions();
      print("Nombre de promotions récupérées : ${promotions.length}");
      return promotions.length;
    } catch (e) {
      print("Erreur lors du comptage des promotions : $e");
      return 0;
    }
  }
}
